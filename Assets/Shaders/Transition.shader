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
			float _TransitionRatio;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 currentRender = tex2D(_MainTex, i.uv);
				fixed4 previousRender = tex2D(_TransitionTexture, i.uv);

				fixed4 color = lerp(previousRender, currentRender, _TransitionRatio);
				return color;
			}
			ENDCG
		}
	}
}
