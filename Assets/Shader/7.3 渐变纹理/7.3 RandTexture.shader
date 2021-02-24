Shader "Custom/7.3 RandTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_RampTexture("RampTexture",2D) = "white" {}
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="ForwardBase" }

        CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"

		//todo:定义变量

        ENDCG
    }
    FallBack "Diffuse"
}
