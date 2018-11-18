Shader "Custom/Waves" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveA("Wave A (dirX, dirY, steepness, wavelength)", Vector) = (0.3,0.8,0.9,10)
		_WaveB("Wave B (dirX, dirY, steepness, wavelength)", Vector) = (0.3,0.8,0.6,10)
		_WaveC("Wave C (dirX, dirY, steepness, wavelength)", Vector) = (0.3,0.8,0.3,10)

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
		float4 _WaveA, _WaveB, _WaveC;

		void generateWave (inout appdata_full vertexData, float4 _Wave, float3 tangent, float3 binormal) {
			
			float steepness = _Wave.z;
			float wavelength = _Wave.w;
			float T = 2 * UNITY_PI / wavelength;
			float C = sqrt(9.8 / T);
			float2 D = normalize(_Wave.xy);
			float F = T * (dot(D, vertexData.vertex.xz) - C * _Time.y);
			float A = steepness / T;

			vertexData.vertex.xz += D.xy * (A * cos(F));
			vertexData.vertex.y = A*sin(F);

			tangent += float3(
				- D.x * D.x * (steepness*sin(F)),
				D.x * steepness*cos(F),
				-D.x * D.y * steepness*sin(F)
				);

			binormal += float3(
				-D.x * D.y * steepness*sin(F),
				D.y * steepness*cos(F),
				- D.y * D.y * steepness*sin(F)
				);

		}


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
			
			void vert(inout appdata_full vertexData) {
				float3 tangent = float3(1, 0, 0);
				float3 binormal = float3(0, 0, 1);
				generateWave(vertexData, _WaveA, tangent, binormal);
				//generateWave(vertexData, _WaveB, tangent, binormal);
				//generateWave(vertexData, _WaveC, tangent, binormal);
				vertexData.normal = normalize(cross(binormal, tangent));
				
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
