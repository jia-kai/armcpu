/*
 * $File: quantize.hh
 * $Date: Wed Dec 18 20:43:42 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#pragma once

#include "matrix.hh"

/*!
 * context-aware quantization for 2D matrices
 */
Matrix<int> quantize(const Matrix<int> &input, int input_quant_size,
		int output_quant_size);

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

