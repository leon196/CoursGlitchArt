Shader "Custom/Particles Position" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_SpawnTexture ("Spawn Texture", 2D) = "white" {}
		_Speed ("Speed", Float) = 0.1
		_SpawnSpeed ("Spawn Speed", Float) = 0.1
		_SlowRatio ("Slow Ratio", Range(0,1)) = 0.5
		_NoiseSpeed ("Noise Speed", Vector) = (1.1, 1.5, 2.0)
		_NoiseScale ("Noise Scale", Vector) = (1.1, 1.5, 2.0)
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Utils.cginc"
			
			sampler2D _MainTex;
			sampler2D _SpawnTexture;
			float _Speed, _SpawnSpeed, _SlowRatio;
			float3 _NoiseSpeed, _NoiseScale;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 position = tex2D(_MainTex, i.uv);
				fixed4 original = tex2D(_SpawnTexture, i.uv);

				float slow = step(_SlowRatio, rand(original.xz));

				float3 velocity = float3(0,0,0);

				float3 tt = float3(_Time.y * _NoiseSpeed.x, _Time.y * _NoiseSpeed.y, _Time.y * _NoiseSpeed.z);
				float nx = noiseIQ((position + original) * _NoiseScale.x + tt.x);
				float ny = noiseIQ((position + original) * _NoiseScale.y + tt.y);
				float nz = noiseIQ((position + original) * _NoiseScale.z + tt.z);
				velocity += float3(nx, ny, nz) * 2. - 1.;

				velocity += normalize(position);

				position.xyz += velocity * _Speed;

				position.w += _SpawnSpeed * (rand(i.uv) * 0.9 + 0.1);
				position = lerp(position, original, step(1, position.w));
				position.w = position.w % 1;

				return position;
			}
			ENDCG
		}
	}
}