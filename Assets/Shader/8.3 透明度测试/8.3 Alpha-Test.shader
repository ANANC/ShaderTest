Shader "Custom/8.3 Alpha-Test"
{
    Properties
    {
        _Color ("漫反射颜色", Color) = (1,1,1,1)
        _MainTex ("纹理图", 2D) = "white" {}
        _Cutoff("透明度" , Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags 
		{ 
			"Queue" = "AlphaTest"
			"IgnoreProjector" = "Ture"
			"RenderType"="TransparentCutout"
		}

		Pass 
		{
			CGPROGRAM							//开始渲染标志位

			#pragma vertex vert					//定义顶点着色器的名字
			#pragma fragment frag				//定义片元着色的名字

			#include "Lighting.cginc"

			ENDCG
		}


    }
    FallBack "Specular"
}
