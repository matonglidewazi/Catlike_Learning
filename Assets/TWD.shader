// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TWD" {

	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_MainTex_ST("tiling", Vector) = (1,1,1,1)
		_DetailTex("Detail Texture", 2D) = "gray" {}
		_DetailTex_ST("Detailed tiling", Vector) = (1,1,1,1)
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
			sampler2D _MainTex, _DetailTex;;
			float4 _MainTex_ST, _DetailTex_ST;
			//tiling vector


			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
			};

			struct VertexData {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators MyVertexProgram(
				VertexData v
			) {
				Interpolators i;
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
				i.position = UnityObjectToClipPos(v.position);
				return i;
			}
		
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				//return float4(i.uv, 1, 1);
				float4 color = tex2D(_MainTex, i.uv) * _Tint;
				color *= tex2D(_DetailTex, i.uvDetail)*unity_ColorSpaceDouble; //this is 2 in gamma space and 4.59 in linear space
				return color;
			}
		
			ENDCG
			//indicate end of code	

		}
	}
}
