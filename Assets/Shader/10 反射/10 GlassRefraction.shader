Shader "Custom/10 GlassRefraction"
{
    Properties
    {
		_MainTex("纹理",2D) = "white" {}
		_BumpMap("法线纹理",2D) = "bump" {}
		_Cubemap("环境纹理",Cube) = "_Skybox" {}
		_Distortion("扭曲系数",Range(0,100)) = 10
		_RefractiAmount("折射系数",Range(0.0,1.0) = 1.0
			}
			SubShader
			{
					Tags{
						"Queue" = "Transparent"
						"RenderType" = "Opaque"
					}

					GrabPass{"_RefractionTex"}

					Pass
					{
						CGPROGRAM

						#pragma vertex vert
						#pragma fragment frag

						#include "Lighting.cginc"

						sampler2D _MainTex;
						float4 _MainTex_ST;
						sampler2D _BumpMap;
						float4 _BumpMap_ST;
						samplerCUBE _Cubemap;
						float _Distortion;
						fixed _RefractAmount;
						smapler2D _RefractionTex;
						float4 _RefractionTex_TexelSize;




				ENDCG
			}
    }
    FallBack "Diffuse"
}
