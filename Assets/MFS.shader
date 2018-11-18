// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MFS" {

	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_MainTex_ST("tiling", Vector) = (1,1,1,1)
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			//tiling vector


			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
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
				return i;
			}
		
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				//return float4(i.uv, 1, 1);
				return tex2D(_MainTex, i.uv);
			}
		
			ENDCG
			//indicate end of code	

		}
	}
}
