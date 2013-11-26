.section .data
.align 4 # which either means 4 or 2**4 depending on arch!

.global _binary_obj_user_prime_start
.type _binary_obj_user_prime_start, @object
_binary_obj_user_prime_start:
.incbin "obj/user/prime"

.align 4
.global _binary_obj_user_prime_end
_binary_obj_user_prime_end:

