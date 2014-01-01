/*
 * $File: main.cc
 * $Date: Wed Jan 01 21:46:26 2014 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include "quantize.hh"
#include <cstdio>

#include <thread>
#include <opencv2/opencv.hpp>

static constexpr int HEIGHT = 300, WIDTH = 400;

void test_quantize() {
	int input_quant_size, nrow, ncol;
	scanf("%d%d%d", &input_quant_size, &nrow, &ncol);
	Matrix<int> input(nrow, ncol);
	for (int i = 0; i < nrow; i ++) {
		auto row = input.ptr(i);
		for (int j = 0; j < ncol; j ++)
			scanf("%d", row + j);
	}
	auto output = quantize(input, input_quant_size, 4);
	for (int i = 0; i < nrow; i ++) {
		auto row = output.ptr(i);
		for (int j = 0; j < ncol; j ++)
			printf("%d ", row[j]);
		printf("\n");
	}
}

static void quantize_channel_tc256(cv::Mat &img, int ch, int dest_quant_size) {
	dassert(img.type() == CV_8UC3);
	Matrix<int> tmp(img.rows, img.cols);
	for (int i = 0; i < tmp.get_nr_row(); i ++) {
		auto src = img.ptr<cv::Vec3b>(i);
		auto dest = tmp.ptr(i);
		for (int j = 0;j < tmp.get_nr_col(); j ++)
			dest[j] = src[j][ch];
	}
	tmp = quantize(tmp, 256, dest_quant_size);
	double f = 255.0 / (dest_quant_size - 1);
	for (int i = 0; i < tmp.get_nr_row(); i ++) {
		auto src = tmp.ptr(i);
		auto dest = img.ptr<cv::Vec3b>(i);
		for (int j = 0;j < tmp.get_nr_col(); j ++)
			dest[j][ch] = round(double(src[j]) * f);
	}
}

static void quantize_channel_naive(cv::Mat &img, int ch, int dest_quant_size) {
	dassert(img.type() == CV_8UC3);
	double f = 255.0 / (dest_quant_size - 1);
	for (int i = 0; i < img.rows; i ++) {
		auto row = img.ptr<cv::Vec3b>(i);
		for (int j = 0; j < img.cols; j ++)
			row[j][ch] = round(row[j][ch] / f) * f;
	}
}

static void quantize_channel_dither(cv::Mat &img, int ch, int dest_quant_size) {
	dassert(img.type() == CV_8UC3);
	double f = 255.0 / (dest_quant_size - 1);
	auto chg = [](uint8_t &v, int d) {
		int t = v;
		t += d;
		if (t < 0)
			t = 0;
		if (t > 255)
			t = 255;
		v = t;
	};
	for (int i = 0; i < img.rows; i ++) {
		auto row = img.ptr<cv::Vec3b>(i),
			 row_next = img.ptr<cv::Vec3b>(std::min(i + 1, img.rows - 1));
		for (int j = 0; j < img.cols; j ++) {
			int old = row[j][ch];
			row[j][ch] = round(row[j][ch] / f) * f;
			int error = old - row[j][ch];
			if (j + 1 < img.cols)
				chg(row[j + 1][ch], error * 7 / 16);
			if (i + 1 < img.rows) {
				if (j)
					chg(row_next[j - 1][ch], error * 3 / 16);
				chg(row_next[j][ch], error * 5 / 16);
				if (j + 1 < img.cols)
					chg(row_next[j + 1][ch], error / 16);
			}
		}
	}
}

static cv::Mat quantize(cv::Mat &img,
		std::function<void(cv::Mat&,int,int)> quantize_channel) {
	auto output = img.clone();
	auto wrapper = [&](cv::Mat *img, int ch, int dest_quant_size) {
		quantize_channel(*img, ch, dest_quant_size);
	};
	std::thread
		worker_b(wrapper, &output, 0, 4),
		worker_g(wrapper, &output, 1, 8),
		worker_r(wrapper, &output, 2, 8);

	worker_b.join();
	worker_g.join();
	worker_r.join();

	return output;
}

static int rgb_to_8bit(int r, int g, int b) {
	r = round(r * 7 / 255.0);
	g = round(g * 7 / 255.0);
	b = round(b * 3 / 255.0);
	return (r << 5) | (g << 2) | b;
}

static void write_bin(cv::Mat &img, const char *fname) {
	assert(img.type() == CV_8UC3);
	uint8_t result[HEIGHT * WIDTH];
	for (int i = 0; i < HEIGHT; i ++) {
		auto row = img.ptr<cv::Vec3b>(i);
		for (int j = 0; j < WIDTH; j ++)
			result[i * WIDTH + j] =
				rgb_to_8bit(row[j][2], row[j][1], row[j][0]);
	}
	FILE *fout = fopen(fname, "wb");
	fwrite(result, 1, HEIGHT * WIDTH, fout);
	fclose(fout);

	for (int i = 0; i < HEIGHT; i ++) {
		auto row = img.ptr<cv::Vec3b>(i);
		for (int j = 0; j < WIDTH; j ++) {
			int v = result[i * WIDTH + j],
				r = v >> 5, g = (v >> 2) & 7, b = v & 3;
			r = r * 255 / 7;
			g = g * 255 / 7;
			b = b * 255 / 3;
			row[j] = cv::Vec3b(b, g, r);
		}
	}
}

int main(int argc, char **argv) {
	if (argc < 4) {
		fprintf(stderr, "usage: %s <input image> <algorithm> <output bin fname>"
				" [to display]\n",
				argv[0]);
		return -1;
	}
	cv::Mat input = cv::imread(argv[1], CV_LOAD_IMAGE_COLOR), output;
	cv::resize(input, input, cv::Size(WIDTH, HEIGHT));

	if (!strcmp(argv[2], "tc256"))
		output = quantize(input, quantize_channel_tc256);
	else if (!strcmp(argv[2], "naive"))
		output = quantize(input, quantize_channel_naive);
	else if (!strcmp(argv[2], "dither"))
		output = quantize(input, quantize_channel_dither);

	write_bin(output, argv[3]);

	cv::imwrite((std::string(argv[3]) + ".png").c_str(), output);

	if (argc > 4) {
		cv::imshow("input", input);
		cv::imshow("output", output);
		cv::waitKey(-1);
	}
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

