Shader "Hidden/Baking"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			sampler2D _PositionTexture;
			sampler2D _ColorTexture;
			sampler2D _NormalTexture;
			float4x4 _MatrixWorldToLocal;
			float3 _SpherePosition;
			float3 _TransformPosition;
			float _SphereRadius;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 buffer = tex2D(_MainTex, i.uv);
				fixed4 pos = tex2D(_PositionTexture, i.uv);
				fixed4 normal = tex2D(_NormalTexture, i.uv);
				fixed4 color = tex2D(_ColorTexture, i.uv);

				float3 spherePosition = mul(_MatrixWorldToLocal, _SpherePosition - _TransformPosition);

				float ratio = 1.0 - smoothstep(0.0, _SphereRadius, length(spherePosition - pos));

				buffer = lerp(buffer, normal, ratio);
				buffer = lerp(buffer, color, 0.05);

				return buffer;
			}
			ENDCG
		}
	}
}
