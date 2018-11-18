Shader "Custom/Waves" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Steepness("Steepness", Range(0,1)) = 0.5
		_Wavelength ("Wavelength", Float) = 10
		_Speed("Speed", Float) = 1

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert addshadow 

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Wavelength;
		float _Speed;
		float _Steepness;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

			
			void vert(inout appdata_full vertexData) {
				float T = 2 * UNITY_PI / _Wavelength;
				float F = T * (vertexData.vertex.x - _Speed * _Time.y);
				vertexData.vertex.x += (_Steepness / T) * cos(F);
				vertexData.vertex.y = (_Steepness / T)*sin(F);

				float3 tangent = normalize(float3(1 - _Steepness*sin(F), _Steepness * cos(F), 0));
				vertexData.normal = float3(-tangent.y, tangent.x, 0);
			}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
