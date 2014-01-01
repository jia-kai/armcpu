/*
 * $File: matrix.hh
 * $Date: Wed Dec 18 23:45:16 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#pragma once

#include "utils.hh"
#include <algorithm>
#include <memory>

template<typename scalar_t>
class Matrix {
	std::shared_ptr<scalar_t*> m_row_ptr;
	std::shared_ptr<scalar_t> m_buf;
	int m_nr_row, m_nr_col, m_alloc_nr_row, m_alloc_nr_col;

	void check_range(int r, int c) const {
		dassert(r >= 0 && r < m_nr_row && c >= 0 && c < m_nr_col);
	}

	public:
		Matrix(int nr_row = 0, int nr_col = 0) {
			reallocate(nr_row, nr_col);
		}

		int get_nr_row() const {
			return m_nr_row;
		}

		int get_nr_col() const {
			return m_nr_col;
		}

		void reallocate(int nr_row, int nr_col) {
			m_buf = create_auto_buf<scalar_t>(nr_row * nr_col, true);
			m_row_ptr = create_auto_buf<scalar_t*>(nr_row);
			for (int i = 0; i < nr_row; i ++)
				m_row_ptr.get()[i] = m_buf.get() + i * nr_col;
			m_alloc_nr_row = nr_row;
			m_alloc_nr_col = nr_col;
			m_nr_row = nr_row;
			m_nr_col = nr_col;
		}

		void resize(int nr_row, int nr_col) {
			dassert(nr_row >= 0 && nr_row <= m_alloc_nr_row);
			if (nr_col > m_alloc_nr_col) {
				Matrix tmp(nr_row, nr_col * 2);
				for (int i = 0; i < nr_row; i ++) {
					auto src = ptr(i), dest = tmp.ptr(i);
					std::copy_n(src, m_nr_col, dest);
				}
				*this = tmp;
			}
			m_nr_row = nr_row;
			m_nr_col = nr_col;
		}

		scalar_t* ptr(int row) {
			check_range(row, 0);
			return m_row_ptr.get()[row];
		}

		const scalar_t* ptr(int row) const {
			check_range(row, 0);
			return m_row_ptr.get()[row];
		}

		scalar_t& at(int r, int c) {
			check_range(r, c);
			return ptr(r)[c];
		}

		const scalar_t& at(int r, int c) const {
			check_range(r, c);
			return ptr(r)[c];
		}

		/*!
		 * remove a pixel and remove following pixels leftward on the same row
		 */
		void rm_colleft(int row, int col) {
			check_range(row, col);
			auto p = ptr(row);
			for (int i = col; i + 1 < m_nr_col; i ++)
				p[i] = p[i + 1];
		}

		/*!
		 * insert a pixel at the left of specified position and move following
		 * co-row pixels rightward
		 */
		void insert_col_after(int row, int col, const scalar_t &v) {
			check_range(row, col + 1);
			if (col >= m_alloc_nr_col)
				resize(m_nr_row, m_alloc_nr_col * 2);
			auto p = ptr(row);
			for (int i = m_nr_col; i > col; i --)
				p[i] = p[i - 1];
			p[col] = v;
		}

		Matrix clone() const {
			Matrix rst(m_nr_row, m_nr_col);
			for (int i = 0; i < m_nr_row; i ++)
				std::copy_n(ptr(i), m_nr_col, rst.ptr(i));
			return rst;
		}

		int size() const {
			return m_nr_row * m_nr_col;
		}
};

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

