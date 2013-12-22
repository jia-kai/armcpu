/*
 * $File: img2bin.cc
 * $Date: Sun Dec 22 11:51:20 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <opencv2/opencv.hpp>
#include <cmath>
#include <cstdio>
#include <cassert>
#include <algorithm>

static const int HEIGHT = 300, WIDTH = 400;

static int rgb_to_8bit(int r, int g, int b) {
	r = round(r * 7 / 255.0);
	g = round(g * 7 / 255.0);
	b = round(b * 3 / 255.0);
	return (r << 5) | (g << 2) | b;
}

int main(int argc, char **argv) {
	if (argc != 3) {
		fprintf(stderr, "usage: %s <input image> <output bin>\n", argv[0]);
		return -1;
	}

	cv::Mat img = cv::imread(argv[1], CV_LOAD_IMAGE_COLOR);
	cv::resize(img, img, cv::Size(WIDTH, HEIGHT));
	cv::Mat orig = img.clone();

	uint8_t result[HEIGHT * WIDTH];
	for (int i = 0; i < HEIGHT; i ++) {
		auto row = img.ptr<cv::Vec3b>(i);
		for (int j = 0; j < WIDTH; j ++)
			result[i * WIDTH + j] = rgb_to_8bit(row[j][2], row[j][1], row[j][0]);
	}

	FILE *fout = fopen(argv[2], "wb");
	fwrite(result, 1, HEIGHT * WIDTH, fout);
	fclose(fout);

	img = cv::Mat(HEIGHT, WIDTH, CV_32FC3);
	for (int i = 0; i < HEIGHT; i ++) {
		auto row = img.ptr<cv::Vec3f>(i);
		for (int j = 0; j < WIDTH; j ++) {
			int v = result[i * WIDTH + j];
			float r = v >> 5, g = (v >> 2) & 7, b = v & 3;
			r /= 7.0;
			g /= 7.0;
			b /= 3.0;
			row[j] = cv::Vec3f(b, g, r);
		}
	}

	cv::imshow("orig", orig);
	cv::imshow("result", img);
	cv::waitKey(-1);
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

