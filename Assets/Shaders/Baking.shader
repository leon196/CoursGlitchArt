Shader "Hidden/Baking"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ColorA ("Color", Color) = (1,1,1,1)
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
			#include "Utils.cginc"
			
			sampler2D _MainTex;
			sampler2D _PositionTexture;
			sampler2D _ColorTexture;
			sampler2D _BrushTexture;
			sampler2D _NormalTexture;
			float4x4 _MatrixWorldToLocal;
			float4 _ColorA;
			float3 _SpherePosition;
			float3 _TransformPosition;
			float2 _Resolution;
			float _SphereRadius;
			float _InputMouseLeft;
			float _InputMouseRight;

			fixed4 getNeighbor (float2 uv, sampler2D layer)
			{
				float2 unit = 1.0 / _Resolution;
				fixed4 north = tex2D(layer, uv + unit * float2(0,1));
				fixed4 south = tex2D(layer, uv + unit * float2(0,-1));
				fixed4 east = tex2D(layer, uv + unit * float2(1,0));
				fixed4 west = tex2D(layer, uv + unit * float2(-1,0));
				fixed4 neighbor = step(0.5, north.z) * north;
				neighbor += step(0.5, south.z) * south;
				neighbor += step(0.5, east.z) * east;
				neighbor += step(0.5, west.z) * west;
				return neighbor;
			}

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 unit = 1.0 / _Resolution;
				fixed4 pos = tex2D(_PositionTexture, i.uv);
				fixed4 normal = tex2D(_NormalTexture, i.uv) * 2. - 1.;
				fixed4 color = tex2D(_ColorTexture, i.uv);

				float3 spherePosition = mul(_MatrixWorldToLocal, _SpherePosition - _TransformPosition);
				float ratio = 1.0 - smoothstep(0.0, _SphereRadius, length(spherePosition - pos));
				
				// float scale = 1.0 / _SphereRadius;
				// float2 uvWorldXY = float2(0,0);
				// float2 uvWorldYZ = float2(0,0);
				// uvWorldXY.x = kaleido((pos - spherePosition).x * scale);
				// uvWorldXY.y = kaleido((pos - spherePosition).y * scale);
				// uvWorldYZ.x = kaleido((pos - spherePosition).y * scale);
				// uvWorldYZ.y = kaleido((pos - spherePosition).z * scale);
				// fixed4 brush = lerp(tex2D(_BrushTexture, uvWorldXY), tex2D(_BrushTexture, uvWorldYZ), 0.5);

				float tint = fmod(noiseIQ(pos + spherePosition * _SphereRadius +normal*3.) * 0.4 + _Time.y*0.2, 1.0);
				// float4 noisy = float4(hsv2rgb(float3(tint,0.8,0.8)), 1.0);
				float4 noisy = float4(float3(1,1,1) * (sin(ratio*40.)*0.5+0.5), 1.0);

				float3 light = normalize(mul(_MatrixWorldToLocal, float3(0,-1,0)));
				// float dotLight = dot(normal, light) * 0.5 + 0.5;

				float3 dir = cross(normal, float3(0,1,0));
				float angle = atan2(dir.z, dir.x);
				float2 offsetBuffer = float2(cos(angle), sin(angle));
				float2 uvBuffer = i.uv + offsetBuffer * unit;
				
				fixed4 buffer = tex2D(_MainTex, i.uv);

				buffer = lerp(buffer, normal, ratio * _InputMouseLeft);
				buffer = lerp(buffer, color, ratio * _InputMouseRight);

				fixed4 debug = pos * 0.5 + 0.5;

				return buffer;
			}
			ENDCG
		}
	}
}
