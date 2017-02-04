Shader "Unlit/GeometryShaderGrid" {
	Properties {
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
		Blend SrcAlpha OneMinusSrcAlpha
		// ZWrite Off

		Cull Off
		LOD 100
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			struct VS_INPUT
			{
				float4 vertex : POSITION;
				float3 normal	: NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct GS_INPUT
			{
				float4 vertex : POSITION;
				float3 normal	: NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct FS_INPUT {
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			GS_INPUT vert (VS_INPUT v)
			{
				GS_INPUT o = (GS_INPUT)0;
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.texcoord = v.texcoord;
				return o;
			}

			[maxvertexcount(3)]
			void geom (line GS_INPUT lin[2], inout TriangleStream<FS_INPUT> triStream)
			{
				FS_INPUT pIn = (FS_INPUT)0;

				// transform
				float4x4 model = UNITY_MATRIX_M;
				// camera
				float4x4 view = UNITY_MATRIX_V;
				// perspective, near/far clip 
				// 3d space -> 2d space camera (viewport)
				float4x4 projection = UNITY_MATRIX_P;

				float4 a = mul(model, lin[0].vertex);
				float4 b = mul(model, lin[1].vertex);
				float4 c = mul(model, lin[0].vertex) + float4(0,0.1,0,0);

				float3 center = (a+b+c)/3.0;

				pIn.vertex = mul(projection, mul(view, a));
				pIn.texcoord = lin[0].texcoord;
				pIn.normal = lin[0].normal;
				triStream.Append(pIn);

				pIn.vertex = mul(projection, mul(view, b));
				pIn.texcoord = lin[1].texcoord;
				pIn.normal = lin[1].normal;
				triStream.Append(pIn);

				pIn.vertex = mul(projection, mul(view, c));
				pIn.texcoord = lin[0].texcoord;
				pIn.normal = lin[0].normal;
				triStream.Append(pIn);
			}

			float4 frag (FS_INPUT i) : COLOR
			{
				float2 uv = i.texcoord;
				float4 color = tex2D(_MainTex, uv);
				return color;
			}
			ENDCG
		}
	}
}
