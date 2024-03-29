Shader "ImageEffect/PixelColorDistort" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_TintTex ("Base (RGB)", 2D) = "" {}
		_Zoom("Zoom in/out bounce", Float) = 0
	}
	// Shader code pasted into all further CGPROGRAM blocks
	CGINCLUDE
		
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uv2 : TEXCOORD1;
	};
	
	sampler2D _MainTex;
	sampler2D _TintTex;
	float _Zoom;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv.xy =  v.texcoord.xy;
		//o.uv.xy = TRANSFORM_TEX(v.texcoord, _TintTex);
		//o.uv.xy =  v.texcoord.xy * _ScreenParams.xy;  
		return o; 
	}

	float2 vCrtCurvature (float2 uv, float q) {
		float x = 1.0 - distance (uv, float2 (0.5, 0.5));
		float2 g = float2(0.5, 0.5) - uv;
		return uv + g*x*q;
	}


	half4 frag(v2f i) : SV_Target 
	{
		i.uv = vCrtCurvature(i.uv, cos(_Time.z * 5.0) * 0.1 * _Zoom + 0.1);
		//i.uv = vCrtCurvature(i.uv, 0.1);

		half4 color = tex2D(_MainTex, i.uv.xy);
		
		float n = 6.0;
		float x = (1.0/n) * ((_ScreenParams.x * i.uv.x) % n);
		float y = (1.0/n) * ((_ScreenParams.y * i.uv.y) % n);
		
		//x = clamp(x, 0.1, 1);
		//y = clamp(y, 0.1, 1);
		


		float2 uv3 = float2(x,y);
		
		
		//float2 uv2 = float2((_ScreenParams.x * i.uv.x)%3, (_ScreenParams.y * i.uv.y)%3;
		
		half4 color3 = half4(x,y,0,0);
		half4 color2 = tex2D(_TintTex, uv3);
		//half4 color2 = tex2D(_TintTex, float2(0.3,0));
		
		//return color2;
		
		half4 result = color + color2 * 0.05;
		if(((_ScreenParams.y * i.uv.y) % 2) < 1)
		{
			result *= 0.8;
		}
		return result;
		//return color - color2 * 0.1;
		//return color - ((color2 * cos(_Time * 30)) * 0.);
		//return half4(uv3.x,uv3.y,0,0);
	}

	ENDCG
	
Subshader 
{
 Blend One Zero
 Pass {
	  ZTest Always Cull Off ZWrite Off
	  Fog { Mode off }      

      CGPROGRAM
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma vertex vert
      #pragma fragment frag
      
      ENDCG
  } // Pass
} // Subshader

Fallback off

} // shader