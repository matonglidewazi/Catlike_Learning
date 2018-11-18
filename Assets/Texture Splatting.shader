
Shader "Custom/Texture Splatting" {

	Properties{
		_MainTex ("Splat Map", 2D) = "white" {}
		_MainTex_ST("tiling", Vector) = (1,1,1,1)
		[NoScaleOffset] _Texture1 ("Texture 1", 2D) = "white" {}
		[NoScaleOffset] _Texture2 ("Texture 2", 2D) = "white" {}
	}

	subshader{
		Pass{
		//a pass is where objs are rendered

			CGPROGRAM
			//indicade start of code
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex, _Texture1, _Texture2;
			float4 _MainTex_ST;
			//tiling vector


			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
			};

			struct VertexData {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators MyVertexProgram(
				VertexData v
			) {
				Interpolators i;
				//i.uv = v.uv*_MainTex_ST.xy + _MainTex_ST.zw;
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.position = UnityObjectToClipPos(v.position);
				i.uvSplat = v.uv;
				return i;
			}
		
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				//return float4(i.uv, 1, 1);
				float4 splat = tex2D(_MainTex, i.uvSplat);
				return tex2D(_Texture1, i.uv) * splat.r +
					tex2D(_Texture2, i.uv) * (1 - splat.r);
			}
		
			ENDCG
			//indicate end of code	

		}
	}
}
