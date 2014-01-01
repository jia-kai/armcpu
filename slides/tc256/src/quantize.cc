/*
 * $File: quantize.cc
 * $Date: Mon Dec 23 10:51:03 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include "quantize.hh"
#include "network_flow.hh"
#include "utils.hh"
#include "math.hh"

static constexpr int
	WEIGHT_ORIG = 2,	// weight for difference with original pixels
	WEIGHT_INTER = 3;	// weight for difference between adjacent pixels

Matrix<int> quantize(const Matrix<int> &input, int input_quant_size,
		int output_quant_size) {

	dassert(input_quant_size <= (1 << 20));
	dassert(input_quant_size >= output_quant_size * 4 &&
			output_quant_size >= 4);
	std::vector<int> quant_lower(input_quant_size);
	std::vector<double>
		quant_rev_lower(input_quant_size),
		quant_rev_upper(input_quant_size);
	double quant_factor = double(output_quant_size - 1) / (input_quant_size - 1),
		   quantseg = 1.0 / quant_factor,
		   quantseg_half = quantseg / 2;
	for (int i = 0; i < input_quant_size; i ++) {
		double val = i * quant_factor;
		int lower = ifloor(val);
		quant_lower[i] = lower;
		quant_rev_lower[i] = lower * quantseg,
		quant_rev_upper[i] = (lower + 1) * quantseg;
	}

	int svtx = input.size(), tvtx = svtx + 1;

	// for the minimal cut,
	// v in S: v quantized to lower bound
	// v in T: v quantized to upper bound
	NetworkFlow network(tvtx + 1, svtx, tvtx);

	std::vector<double>
		vtx_cost_as_lower(input.size()),
		vtx_cost_as_higher(input.size());

	// cost for difference between with original value
	for (int i = 0, num = 0; i < input.get_nr_row(); i ++) {
		auto row = input.ptr(i);
		for (int j = 0; j < input.get_nr_col(); j ++) {
			int v = row[j];
			vtx_cost_as_higher[num] = (quant_rev_upper[v] - v) * WEIGHT_ORIG;
			vtx_cost_as_lower[num] = (v - quant_rev_lower[v]) * WEIGHT_ORIG;
			num ++;
		}
	}

	auto add_adjacent = [&](int vtx0, int q0, int vtx1, int q1) {
		if (q0 > q1) {
			std::swap(q0, q1);
			std::swap(vtx0, vtx1);
		}
		if (q1 - q0 >= quantseg)
			return;

		double
			l0 = quant_rev_lower[q0],
			u0 = quant_rev_upper[q0],
			l1 = quant_rev_lower[q1],
			u1 = quant_rev_upper[q1],
			ell = fabs(l0 - l1 - (q0 - q1)) * WEIGHT_INTER,
			elu = fabs(l0 - u1 - (q0 - q1)) * WEIGHT_INTER,
			eul = fabs(u0 - l1 - (q0 - q1)) * WEIGHT_INTER,
			euu = fabs(u0 - u1 - (q0 - q1)) * WEIGHT_INTER;
		dassert(fabs(ell - euu) < EPS);
		if (q1 - q0 <= quantseg_half) {
			if (quant_lower[q0] != quant_lower[q1]) {
				dassert(quant_rev_upper[q0] == quant_rev_lower[q1]);
				dassert(eul <= ell && eul <= elu);
				auto v0l = ell - eul,
					 v1h = euu - eul;
				dassert(v0l >= 0 && v1h >= 0);
				vtx_cost_as_lower[vtx0] += v0l;
				vtx_cost_as_higher[vtx1] += v1h;
				dassert(fabs(elu - eul - v0l - v1h - 2 * eul) < EPS);
				network.add_arc(vtx0, vtx1, iround(2 * eul));
			} else {
				network.add_arc(vtx0, vtx1, iround(elu - ell));
				network.add_arc(vtx1, vtx0, iround(eul - ell));
			}
		} else {
			if (quant_lower[q0] != quant_lower[q1]) {
				dassert(quant_rev_upper[q0] == quant_rev_lower[q1]);
				network.add_arc(vtx0, vtx1, iround(elu - ell));
				network.add_arc(vtx1, vtx0, iround(eul - ell));
			} else {
				dassert(elu <= ell && elu <= eul);
				auto v0u = euu - elu,
					 v1l = ell - elu;
				dassert(v0u >= 0 && v1l >= 0);
				vtx_cost_as_higher[vtx0] += v0u;
				vtx_cost_as_lower[vtx1] += v1l;
				dassert(fabs(eul - elu - v0u - v1l -
							2 * (quantseg * WEIGHT_INTER - ell)) < EPS);
				network.add_arc(vtx1, vtx0, iround(eul - elu - v0u - v1l));
			}
		}
	};

	// cost for difference between adjacent values
	for (int i = 0; i < input.get_nr_row(); i ++) {
		const int *row = input.ptr(i),
			 *row_prev = i ? input.ptr(i - 1) : nullptr;
		int rnum = i * input.get_nr_col(),
			rnum_prev = rnum - input.get_nr_col();
		for (int j = 0; j < input.get_nr_col(); j ++) {
			if (j) {
				add_adjacent(rnum + j - 1, row[j - 1],
						rnum + j, row[j]);
			}
			if (i) {
				add_adjacent(rnum_prev + j, row_prev[j],
						rnum + j, row[j]);
			}
		}
	}

	// add arcs for vertex cost
	for (int i = 0; i < input.size(); i ++) {
		network.add_arc(svtx, i, vtx_cost_as_higher[i]);
		network.add_arc(i, tvtx, vtx_cost_as_lower[i]);
	}

	int tot_cost = network.calc_maxflow();
	log_printf("total cost: %d", tot_cost);

	std::vector<int> cut_map;
	network.get_minimal_cut_map(cut_map);


	auto result = input.clone();
	for (int i = 0, num = 0; i < input.get_nr_row(); i ++) {
		auto dest = result.ptr(i);
		for (int j = 0; j < input.get_nr_col(); j ++) {
			auto &t = dest[j];
			t = cut_map[num ++] + quant_lower[t];
			if (t == output_quant_size)
				t --;
			dassert(t >= 0 && t < output_quant_size);
		}
	}

	return result;
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

