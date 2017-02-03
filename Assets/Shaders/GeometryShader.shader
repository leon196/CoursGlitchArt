Shader "Unlit/GeometryShader" {
	Properties {
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		Cull Off
		LOD 100
		Pass {
			CGPROGRAM
			#pragma exclude_renderers gles
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
			void geom (triangle GS_INPUT tri[3], inout TriangleStream<FS_INPUT> triStream)
			{
				FS_INPUT pIn = (FS_INPUT)0;

				float4x4 model = UNITY_MATRIX_M;
				float4x4 view = UNITY_MATRIX_V;
				float4x4 projection = UNITY_MATRIX_P;

				float4 a = mul(model, tri[0].vertex);
				float4 b = mul(model, tri[1].vertex);
				float4 c = mul(model, tri[2].vertex);

				float3 center = (a+b+c)/3.0;
				float3 seed = (center + float3(_Time.y,_Time.y+48.4,_Time.y-65.0)) / 2.0;
				float3 offset = float3(noiseIQ(seed), noiseIQ(seed+3.5), noiseIQ(seed+15.8));
				a.xyz += offset;
				b.xyz += offset;
				c.xyz += offset;

				float angleX = rand(center) * (sin(_Time.y)*0.5+0.5);
				float angleY = rand(center) * (sin(_Time.y)*0.5+0.5);
				a.xyz = rotateY(rotateX(a, angleX), angleY);
				b.xyz = rotateY(rotateX(b, angleX), angleY);
				c.xyz = rotateY(rotateX(c, angleX), angleY);

				pIn.vertex = mul(projection, mul(view, a));
				pIn.texcoord = tri[0].texcoord;
				pIn.normal = tri[0].normal;
				triStream.Append(pIn);

				pIn.vertex = mul(projection, mul(view, b));
				pIn.texcoord = tri[1].texcoord;
				pIn.normal = tri[1].normal;
				triStream.Append(pIn);

				pIn.vertex = mul(projection, mul(view, c));
				pIn.texcoord = tri[2].texcoord;
				pIn.normal = tri[2].normal;
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
