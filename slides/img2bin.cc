/*
 * $File: img2bin.cc
 * $Date: Fri Dec 13 20:26:14 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <opencv2/opencv.hpp>
#include <cmath>
#include <cstdio>
#include <cassert>
#include <algorithm>

static const int HEIGHT = 300, WIDTH = 400;

static const auto COLOR_CONVERT = CV_BGR2Lab;

struct VecColor {
	float x, y, z;

	float dist(const VecColor &v) const {
		auto d0 = x - v.x, d1 = y - v.y, d2 = z - v.z;
		/*
		d0 = fabs(d0);
		d0 = std::min(d0, 360 - d0);
		d0 /= 180;
		*/
		d0 /= 100;
		d1 /= 127;
		d2 /= 127;
		return sqrt(d0 * d0 + d1 * d1 + d2 * d2);
	}
};

static VecColor palette_lab[256];

static void init_palatte();
static int lab_to_8bit(const VecColor &v);

int lab_to_8bit(const VecColor &v) {
	float min_dist = v.dist(palette_lab[0]);
	int val = 0;
	for (int i = 1; i < 256; i ++) {
		float d = v.dist(palette_lab[i]);
		if (d < min_dist) {
			min_dist = d;
			val = i;
		}
	}
	return val;
}

void init_palatte() {
	cv::Mat img(256, 1, CV_32FC3);
	for (int i = 0; i < 256; i ++) {
		float r = i >> 5, g = (i >> 2) & 7, b = i & 3;
		r /= 7.0;
		g /= 7.0;
		b /= 3.0;
		img.at<cv::Vec3f>(i) = cv::Vec3f(b, g, r);
	}
	cv::cvtColor(img, img, COLOR_CONVERT);
	for (int i = 0; i < 256; i ++)
		palette_lab[i] = img.at<VecColor>(i);
}

int main(int argc, char **argv) {
	if (argc != 3) {
		fprintf(stderr, "usage: %s <input image> <output bin>\n", argv[0]);
		return -1;
	}

	init_palatte();

	cv::Mat img = cv::imread(argv[1], CV_LOAD_IMAGE_COLOR);
	cv::resize(img, img, cv::Size(WIDTH, HEIGHT));
	img.convertTo(img, CV_32FC3, 1.0 / 255);
	cv::Mat orig = img.clone();
	cv::cvtColor(img, img, COLOR_CONVERT);

	uint8_t result[HEIGHT * WIDTH];
	for (int i = 0; i < HEIGHT; i ++) {
		auto row = img.ptr<VecColor>(i);
		for (int j = 0; j < WIDTH; j ++)
			result[i * WIDTH + j] = lab_to_8bit(row[j]);
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

