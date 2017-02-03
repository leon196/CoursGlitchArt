Shader "Unlit/Storm"
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
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;
				float4 vertex = mul(unity_ObjectToWorld, v.vertex);

				float size = v.texcoord1.x;
				float3 anchor = float3(v.texcoord1.y,v.texcoord2.xy);

				float3 hsv = hsv2rgb(float3(rand(anchor.xy),0.8,0.8));
				o.color = float4(hsv, 1.);

				float angleAnchor = _Time.y*.2;
				anchor = rotateY(anchor, angleAnchor);

				float angleX = _Time.y*.02 / size;
				float angleY = _Time.y*.03 / size;
				vertex.xyz = rotateY(rotateX(vertex - anchor, angleX), angleY) + anchor;

				o.vertex = mul(UNITY_MATRIX_VP, vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal = v.normal;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.texcoord) * i.color;
				return color;
			}
			ENDCG
		}
	}
}
