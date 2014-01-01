/*
 * $File: math.hh
 * $Date: Sun Dec 22 17:06:16 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#pragma once

#include "utils.hh"

#include <cmath>

constexpr double EPS = 1e-5;

template<typename T>
T sqr(const T &v) {
	return v * v;
}

template <typename T>
static inline T dot_product(const T *a, const T *b, size_t len) {
	T s = 0;
	for (size_t i = 0; i < len; i ++)
		s += a[i] * b[i];
	return s;
}

template <typename T>
static inline T calc_length(const T *a, size_t len) {
	T s = 0;
	for (size_t i = 0; i < len; i ++)
		s += a[i] * a[i];
	return sqrt(s);
}

template <typename T>
static inline T calc_euclidean_dist(const T *a, const T *b, size_t len) {
	T s = 0;
	for (size_t i = 0; i < len; i ++)
		s += sqr(a[i] - b[i]);
	return sqrt(s);
}

template <typename T>
inline T quadratic_sum(T v0) {
	return v0 * v0;
}

template <typename T, typename... Args>
inline T quadratic_sum(T v0, Args... args) {
	return v0 * v0 + quadratic_sum(args...);
}

template <typename T, typename... Args>
inline T quadratic_sum_sqrt(T v0, Args... args) {
	return sqrt(quadratic_sum(v0, args...));
}

template <typename T>
inline T min(T v0) {
	return v0;
}

template <typename T, typename... Args>
inline T min(T v0, Args... args) {
	T tmp = min(args...);
	if (v0 < tmp)
		return v0;
	return tmp;
}

template <typename T>
inline T max(T v0) {
	return v0;
}

template <typename T, typename... Args>
inline T max(T v0, Args... args) {
	T tmp = max(args...);
	if (v0 > tmp)
		return v0;
	return tmp;
}

template <typename T>
int iceil(T x) {
	return int(ceil(x));
}

template <typename T>
int ifloor(T x) {
	return int(floor(x));
}

template <typename T>
int iround(T x) {
	return ifloor(x + T(0.5));
}

template <typename T>
inline bool update_min(T &) {
	return false;
}

template <typename T, typename... Args>
inline bool update_min(T &target, const T &val, Args... args) {
	bool rst = false;
	if (val < target) {
		rst = true;
		target = val;
	}
	rst |= update_min(target, args...);
	return rst;
}

template <typename T>
inline constexpr T numeric_max() {
	return std::numeric_limits<T>::max();
}


// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

