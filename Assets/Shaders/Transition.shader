Shader "Hidden/Transition"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TransitionTexture ("Transition Texture", 2D) = "white" {}
		_TransitionRatio ("Transition Ratio", Range(0,1)) = 1
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _TransitionTexture;
			sampler2D _CameraTexture;
			float _TransitionRatio;

			// http://stackoverflow.com/questions/12964279/whats-the-origin-of-this-glsl-rand-one-liner
			float rand(float2 co) {
				return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
			}

			float2 pixelize (float2 value, float segments) {
				return ceil(value * segments) / segments;
			}

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;
				uv.x *= 2.;
				// float offset = rand(i.uv.xx);
				// float r = _TransitionRatio;
				// uv.y -= r + lerp(0.,offset, sin(r*3.14159));
				fixed4 currentRender = tex2D(_MainTex, uv);
				fixed4 previousRender = tex2D(_TransitionTexture, uv);
				float ratio = step(0., abs(uv.y-0.5)*2.-1.);

				fixed4 color = currentRender;//lerp(previousRender, currentRender, ratio);

				uv = i.uv;
				uv.y = 1. - uv.y;
				uv.x -= 0.5;
				uv.x *= 2.;
				fixed4 camera = tex2D(_CameraTexture, uv);

				color = lerp(color, camera, step(0.5,i.uv.x));

				return color;
			}
			ENDCG
		}
	}
}
