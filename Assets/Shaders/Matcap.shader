Shader "Unlit/Matcap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Matcap ("Matcap", 2D) = "white" {}
		_Blend ("Blend", Range(0,1)) = 0.5
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			sampler2D _Matcap;
			float4 _MainTex_ST;
			float _Blend;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				float3 viewDir = -normalize(WorldSpaceViewDir(v.vertex));
				// viewDir = normalize(_WorldSpaceLightPos0);
				o.normal = normalize(v.normal);

				float3 av = mul(UNITY_MATRIX_VP, float4(cross(o.normal, viewDir),0));
				float angle = atan2(av.y, av.x);

				float radius = dot(viewDir, o.normal) * 0.5 + 0.5;
				o.uv2 = float2(cos(angle), sin(angle)) * radius * 0.5 - 0.5;
				o.color = v.color;
				o.color.rgb = float3(1,1,1) * dot(viewDir, o.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 matcap = tex2D(_Matcap, i.uv2);
				col = lerp(col, matcap, _Blend);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				// col.rgb = i.normal * 0.5 + 0.5;
				// col.rgb = i.color;
				return col;
			}
			ENDCG
		}
	}
}
