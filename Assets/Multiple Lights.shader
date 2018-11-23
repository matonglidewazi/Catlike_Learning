Shader "Custom/Multiple Lights" {

	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0.1
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
	}

	subshader{
		Pass{

			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			//indicade start of code
			
			#pragma target 3.0
			
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			#define FORWARD_BASE_PASS
			#include "First Lighting Shader.cginc"
		
			ENDCG
			//indicate end of code	

		}

		Pass{

			Tags {
				"LightMode" = "ForwardAdd"
			}

			Blend One One
			ZWrite Off
			//blend mode in frame buffer, turn off zbuffer

			CGPROGRAM
			//indicade start of code
			
			#pragma target 3.0
			#pragma multi_compile_fwdadd
			//DIRECTIONAL DIRECTIONAL_COOKIE POINT POINT_COOKIE SPOT
			//cookie light will always be in additional pass

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			
			#include "First Lighting Shader.cginc"


			ENDCG
			//indicate end of code	

		}


	}
}
