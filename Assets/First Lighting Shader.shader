// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/First Lighting Shader" {

	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
	}

	subshader{
		Pass{

			Tags {
				"LightMode" = "ForwardBase"
				//light dir reversed, strange?
			}

			CGPROGRAM
			//indicade start of code

			#pragma target 3.0
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			#include "UnityStandardBRDF.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityPBSLighting.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Smoothness;
			float _Metallic;
			//tiling vector

			struct VertexData {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			Interpolators MyVertexProgram(
				VertexData v
			) {
				Interpolators i;
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.worldPos = UnityObjectToClipPos(v.position);
				//automatic tiling implement by Unity

				i.position = UnityObjectToClipPos(v.position);
				i.normal = mul(transpose ((float3x3)unity_ObjectToWorld), v.normal);
				i.normal = normalize(i.normal);
				return i;
			}
		
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				i.normal = normalize(i.normal);

				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 lightColor = _LightColor0.rgb;

				float3 viewDir = -normalize(i.worldPos - _WorldSpaceCameraPos);
				//this is a vector point from camera!
				
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

				float3 specularTint = albedo * _Metallic;
				float oneMinusReflectivity;

				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);//also out to oneMinusReflectivity

				//albedo = EnergyConservationBetweenDiffuseAndSpecular(albedo, _SpecularTint.rgb, oneMinusReflectivity);

				UnityLight light;
				light.color = lightColor;
				light.dir = lightDir;
				light.ndotl = DotClamped(i.normal, lightDir); 

				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;


				return UNITY_BRDF_PBS(
					
					albedo, 
					specularTint,
					oneMinusReflectivity, //1-reflecivity
					_Smoothness, //1- roughness
					
					i.normal, 
					viewDir,
					
					light,
					indirectLight

				);


			}
		
			ENDCG
			//indicate end of code	

		}
	}
}
