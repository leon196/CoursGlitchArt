Shader "Unlit/Grid"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float4 vertexWorld : TEXCOORD1;
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;
				float4 vertex = mul(unity_ObjectToWorld, v.vertex);
				o.vertexWorld = vertex;
				o.vertex = mul(UNITY_MATRIX_VP, vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color;
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.texcoord);

				// float lines = sin(i.texcoord.x * 600. + _Time.y);
				// lines = smoothstep(0.9,1.0,lines);
				// color.rgb *= lines;
				color.rgb = abs(i.vertexWorld.x);
				return color;
			}
			ENDCG
		}
	}
}
