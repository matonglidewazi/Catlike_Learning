#ifndef First_Lighting_Shader_H
#define First_Lighting_Shader_H

#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;
float _Smoothness;
float _Metallic;

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

	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD3;
	#endif

};

void ComputeVertexLightColor (inout Interpolators i) {
	#if defined(VERTEXLIGHT_ON)
		i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		);
	#endif
}

Interpolators MyVertexProgram(
	VertexData v
) {
	Interpolators i;
	i.uv = TRANSFORM_TEX(v.uv, _MainTex);
	i.worldPos = mul(unity_ObjectToWorld, v.position);
	i.position = UnityObjectToClipPos(v.position);	
	i.normal = UnityObjectToWorldNormal(v.normal);
	ComputeVertexLightColor(i);
	return i;
}

UnityLight CreateLight (Interpolators i){

	UnityLight light;
	float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;

	//this function define attenuation for us, unity marco acts very strange!
	
	#if !(defined(DIRECTIONAL)) && !(defined(DIRECTIONAL_COOKIE))
		light.dir = normalize (lightVec);
	#else
		light.dir = _WorldSpaceLightPos0;		
	#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	//this take care of range, attenuation of spot, directional and point light

	light.color = _LightColor0.rgb;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;

}

UnityIndirect CreateIndirectLight (Interpolators i) {
	//treating the vertex light color as indirect light.
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif

	#if defined(FORWARD_BASE_PASS)
		indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
	#endif
	return indirectLight;
}

float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
	i.normal = normalize(i.normal);

	float3 viewDir = -normalize(i.worldPos - _WorldSpaceCameraPos);
	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

	float3 specularTint = albedo * _Metallic;
	float oneMinusReflectivity;

	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	return UNITY_BRDF_PBS(
		
		albedo, 
		specularTint,
		oneMinusReflectivity,
		_Smoothness,
		
		i.normal, 
		viewDir,
		
		CreateLight(i),
		CreateIndirectLight(i)

	);

}

#endif
