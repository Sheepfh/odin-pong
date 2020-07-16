package main

detect_collision :: proc(b, c: ^Bounding_Box) -> bool {
	bx1 := b.origin[0]; by1 := b.origin[1];
	bx2 := b.origin[0] + b.width; by2 := b.origin[1] + b.height;

	cx1 := c.origin[0]; cy1 := c.origin[1];
	cx2 := c.origin[0] + c.width; cy2 := c.origin[1] + c.height;

	if (bx1 > cx1 && bx1 < cx2 && by1 > cy1 && by1 < cy2) ||
	   (bx1 > cx1 && bx1 < cx2 && by2 > cy1 && by2 < cy2) ||
	   (bx2 > cx1 && bx2 < cx2 && by2 > cy1 && by2 < cy2) ||
	   (bx2 > cx1 && bx2 < cx2 && by1 > cy1 && by1 < cy2) {

	   	// TODO: find collision's direction
	   	return true;
	}
	else {
		return false;
	}
}