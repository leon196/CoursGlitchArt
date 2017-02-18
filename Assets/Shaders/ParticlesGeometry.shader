// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Particles Geometry" {
	Properties {
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_PositionTexture ("Vertex (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Radius ("Radius", Float) = 0.1
	}
	SubShader {
		// Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
		// Blend SrcAlpha OneMinusSrcAlpha
		// ZWrite Off

		Tags { "RenderType"="Opaque" }

		// Tags { "Queue"="AlphaTest" "RenderType"="Transparent" "IgnoreProjector"="True" }
		// Blend One OneMinusSrcAlpha
		// AlphaToMask On

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
			sampler2D _PositionTexture;
			float4 _MainTex_ST;
			float4 _Color;
			float _Radius;

			struct VS_INPUT
			{
				float4 vertex : POSITION;
				float3 normal	: NORMAL;
				float4 color	: COLOR;
				float4 texcoord2 : TEXCOORD1;
			};

			struct GS_INPUT
			{
				float4 vertex : POSITION;
				float3 normal	: NORMAL;
				float4 color	: COLOR;
				float4 texcoord2 : TEXCOORD1;
			};

			struct FS_INPUT {
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float4 texcoord2 : TEXCOORD1;
			};

			GS_INPUT vert (VS_INPUT v)
			{
				GS_INPUT o = (GS_INPUT)0;
				o.vertex = v.vertex;
				o.color = v.color;
				o.normal = v.normal;
				o.texcoord2 = v.texcoord2;
				return o;
			}

			[maxvertexcount(3)]
			void geom (point GS_INPUT tri[1], inout TriangleStream<FS_INPUT> triStream)
			{
				FS_INPUT pIn = (FS_INPUT)0;
				pIn.texcoord2 = tri[0].texcoord2;
				pIn.color = tri[0].color * _Color;

				// float4 position = tex2Dlod(_PositionTexture, float4(pIn.texcoord2.xy, 0, 0));
				
				float4 position = float4(0,0,0,0);
				position.xz = pIn.texcoord2.xy * 20.;

				float4 vertex = mul(unity_ObjectToWorld, float4(position.xyz, tri[0].vertex.w));
				float radius = _Radius * (rand(pIn.texcoord2.xy) * 0.9 + 0.1);

				float fade = smoothstep(0.0, 0.2, position.w) * (1 - smoothstep(0.8, 1.0, position.w));

				//radius = lerp(radius, 10., position.w);
				// radius *= fade;
				//pIn.color.a *= (rand(pIn.texcoord2.xy) * 0.9 + 0.1) * fade;

				float shade = smoothstep(0., 200.5, position.y);
				// float shade = position.w;
				// pIn.color.rgb = lerp(float3(0,0,0), float3(1,1,1), shade);

				// float3 tangent = radius / 1.5 * normalize(cross(float3(0,1,0), pIn.normal));
				// float3 up = radius / 2 * normalize(cross(tangent, pIn.normal));

				float3 tangent = float3(1.0, 0.0, 0.0) * radius;
				float3 up = float3(0.0, 1.0, 0.0) * radius;

				pIn.vertex = mul(UNITY_MATRIX_VP, vertex) + float4(-tangent + up, 0);
				pIn.texcoord = float2(-0.2,0.05);
				pIn.color = _Color * 0.3;
				triStream.Append(pIn);

				pIn.vertex = mul(UNITY_MATRIX_VP, vertex) + float4(-up, 0);
				pIn.texcoord = float2(0.4,1.4);
				pIn.color = _Color;
				triStream.Append(pIn);

				pIn.vertex = mul(UNITY_MATRIX_VP, vertex) + float4(tangent + up, 0);
				pIn.texcoord = float2(1.4,0.05);
				pIn.color = _Color * 0.3;
				triStream.Append(pIn);
			}

			float4 frag (FS_INPUT i) : COLOR
			{
				return i.color;// * tex2D(_MainTex, i.texcoord);
			}
			ENDCG
		}
	}
}
