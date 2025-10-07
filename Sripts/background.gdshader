shader_type canvas_item;
uniform int NB = 10;

void vertex() {
	// Called for every vertex the material is visible on.
}
float rand_from_int(int i) {
    return fract(sin(float(i) * 12.9898) * 43758.5453);
}
vec4 func_creat_ob(sampler2D tex,vec2 uv,float time1,float time2){
	float x =mod(time1,1.0)*3.0;
	float y =sin(time2)+1.0;
	vec2 shifted_uv = uv*10.0-vec2(y,x)*3.0;
	vec4 clone_color = texture(tex, shifted_uv);
	return clone_color;
}
vec4 gen_all_floc(sampler2D tex,vec2 uv,float time,int nb)
{
	vec4 ob_b=vec4(0,0,0,-1);
	for(int i = 0;i<=nb;i++)
	{
		float t= time/2.0+rand_from_int(i)*100.0;
		vec4 ob= func_creat_ob(tex,uv,t,t);
		if(ob.a>ob_b.a)
		{
			ob_b=ob;
		}
	}
	return ob_b;
}

void fragment() {

    vec4 clone_color1 = func_creat_ob(TEXTURE,UV,TIME,TIME);
	vec4 clone_color2 = func_creat_ob(TEXTURE,UV,TIME+PI,TIME+PI);
	float r = 0.0;
	float g = 1.0;
	float b = 0.0;
	float a = 0.0;
	if(clone_color1.a>clone_color2.a)
	{
		r = clone_color1.r;
		g = clone_color1.g;
		b = clone_color1.b;
		a = clone_color1.a;
	}
	else
	{
		r = clone_color2.r;
		g = clone_color2.g;
		b = clone_color2.b;
		a = clone_color2.a;
	}
		
    //COLOR = vec4(r,g,b,a);
	COLOR = gen_all_floc(TEXTURE,UV,TIME,NB);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
