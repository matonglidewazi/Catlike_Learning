// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/First Lighting Shader" {

	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {} //this is a special start value
		_BumpScale ("Bump Scale", Float) = 1
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

			sampler2D _MainTex;
			sampler2D _HeightMap;
			sampler2D _NormalMap;

			float4 _Tint;

			/*Automatically loaded info*/
			float4 _HeightMap_TexelSize; 
			float4 _MainTex_ST; 

			float _Smoothness;
			float _Metallic;
			float _BumpScale;

			struct VertexData {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tangent : TEXCOORD3;
			};

			Interpolators MyVertexProgram(
				VertexData v
			) {
				Interpolators i;
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.worldPos = UnityObjectToClipPos(v.position);
				//automatic tiling implement by Unity

				i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				//passing the tangent from obj space to world space

				i.position = UnityObjectToClipPos(v.position);
				i.normal = mul(transpose ((float3x3)unity_ObjectToWorld), v.normal);
				i.normal = normalize(i.normal);
				return i;
			}

			void InitializeFragmentNormal_Bump (inout Interpolators i){
				
				float2 delta = float2(_HeightMap_TexelSize.x, _HeightMap_TexelSize.y)*0.5; //central diff
				
				float u1 = tex2D(_HeightMap, i.uv - float2 (delta.x, 0));
				float u2 = tex2D(_HeightMap, i.uv + float2 (delta.x, 0));
				float v1 = tex2D(_HeightMap, i.uv - float2 (delta.y, 0));
				float v2 = tex2D(_HeightMap, i.uv + float2 (delta.y, 0));

				float3 tu = float3(1, u2-u1, 0);
				float3 tv = float3(0, v2-v1, 1);

				i.normal = normalize(
					cross(tv, tu)
				);
			}

			void InitializeFragmentNormal(inout Interpolators i){
				//DXT5 compresses

				float3 tangentSpaceNormal;

				tangentSpaceNormal.xy = (tex2D (_NormalMap, i.uv).wy*2 - 1) * _BumpScale;
				tangentSpaceNormal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
				tangentSpaceNormal.xyz = tangentSpaceNormal.xzy;

				float3 binormal = cross(i.normal, i.tangent.xyz) * i.tangent.w;

				//a synched tangent space workflow: mikktspace
				i.normal = normalize(
					tangentSpaceNormal.x * i.tangent +
					tangentSpaceNormal.y * i.normal + 
					tangentSpaceNormal.z * binormal
				);

			}
		
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				InitializeFragmentNormal(i);
				//init the normal before bump

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
