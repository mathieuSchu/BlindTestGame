shader_type canvas_item;
uniform int NB = 10;
uniform int Size = 10;
uniform float VITESSE = 10;

void vertex() {
	// Called for every vertex the material is visible on.
}
float rand_from_int(int i) {
    return fract(sin(float(i) * 12.9898) * 4358.5453);
}
vec4 func_creat_ob(sampler2D tex,vec2 uv,float time1,float time2,int size){
	float fact_size=10.0/float(size);
	float x =mod(time1,1.0)*4.0*fact_size-1.0*fact_size;
	float y =sin(time2)*3.0*fact_size;
	vec2 shifted_uv = uv*10.0*fact_size-vec2(y,x)*3.0;
	vec4 clone_color = texture(tex, shifted_uv);
	return clone_color;
}
vec4 gen_all_floc(sampler2D tex,vec2 uv,float time,int nb)
{
	vec4 ob_b=vec4(0,0,0,-1);
	for(int i = 0;i<=nb;i++)
	{
		float vitesse=VITESSE/10.0; 
		float t= time*vitesse+rand_from_int(i)*100.0;
		vec4 ob= func_creat_ob(tex,uv,t,t,Size);
		if(ob.a>ob_b.a)
		{
			ob_b=ob;
		}
	}
	return ob_b;
}

void fragment() {

    //COLOR = vec4(r,g,b,a);
	COLOR = gen_all_floc(TEXTURE,UV,TIME,NB);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
