Shader "Unlit/Sketch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_StencilColor ("Stencil Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _StencilColor;

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;
				float4 vertex = mul(unity_ObjectToWorld, v.vertex);
				float3 normal = normalize(mul(unity_ObjectToWorld, v.normal));
				vertex.xyz += normal * 0.02;
				o.vertex = mul(UNITY_MATRIX_VP, vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _StencilColor;
			}
			ENDCG
		}

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
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float3 vertexWorld : TEXCOORD2;
				float4 vertexView : TEXCOORD3;
				float4 screenPos : TEXCOORD4;
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;
				float4 vertex = mul(unity_ObjectToWorld, v.vertex);
				o.vertexWorld = vertex;
				o.vertexView = mul(UNITY_MATRIX_V, vertex);
				o.vertex = mul(UNITY_MATRIX_VP, vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
				o.normal = normalize(mul(unity_ObjectToWorld, v.normal));
				o.color = v.color;
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			float getLines (float p, float size)
			{
				return smoothstep(1.0-size, 1.0, sin(p));
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 screenUV = i.screenPos.xy / i.screenPos.w;
				fixed4 color = tex2D(_MainTex, i.texcoord) * i.color;
				float dotLight = abs(dot(i.normal, float3(1,0	,0)));
				float dotView = dot(i.normal, i.viewDir);
				float size = (1. - abs(dotView)) * 2.;

				float lineScale = 100;
				float dotsScale = 60;
				float brushScale = 20;
				float brush = noiseIQ(screenUV.xyx*brushScale) * 0.2;
				float shadowLight = 1. - smoothstep(0.5, 1.0, dotView);
				float shadowMiddle = (1.-smoothstep(0.6, 0.8	, dotView)) * smoothstep(0.0, 0.5, dotView);
				float shadowHeavy = 1. - smoothstep(0.3,0.35, dotView);

				// float p = (i.vertexWorld.x+i.vertexWorld.y)*lineScale;
				// float p = atan2(i.vertexWorld.x,i.vertexWorld.y)*lineScale;
				// float p = i.vertexWorld.x*lineScale;
				float p = i.vertexView.z * lineScale;

				float lines = getLines(p, size);
				float dots = noiseIQ(i.vertexWorld*dotsScale);
				float grain = rand(i.vertexWorld) * 0.5 + 0.5;

				shadowLight = shadowMiddle * lines * dots;
				// lines = getLines(p*2., size*4.);
				// shadowMiddle = shadowMiddle * lines * dots;

				shadowLight = clamp(1.-shadowLight,0,1);
				shadowMiddle = clamp(1.-shadowMiddle,0,1);
				shadowHeavy = clamp(1.-shadowHeavy,0,1);

				color.rgb *= shadowLight * shadowHeavy;
				return color;
			}
			ENDCG
		}
	}
}
