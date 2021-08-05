// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/12 BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex("主图片",2D) ="write"{}
		_Brightness("亮度",Float) = 1
		_Saturation("饱和度",Float) = 1
		_Contrast("对比度",Float) = 1
	}
		SubShader
		{
			Pass
			{
				ZTest Always Cull Off Zwrite Off	//确保只是渲染当前内容，所以关掉深度
							
				CGPROGRAM
				#pragma vertex vert  
				#pragma fragment frag  

				#include "UnityCG.cginc"  

				sampler2D _MainTex;
				half _Brightness;
				half _Saturation;
				half _Contrast;

				struct v2f {
					float4 pos : SV_POSITION;
					half2 uv:TEXCOORD0;
				};

				v2f vert(appdata_img v)
				{
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;

					return o;
				}

				fixed4 frag(v2f i) :SV_Target{
					//得到纹理
					fixed4 renderTex = tex2D(_MainTex,i.uv);

					//定义最终的颜色
					//亮度控制
					fixed3 finalColor = renderTex.rgb * _Brightness;

					//饱和度控制
					fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
					fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
					finalColor = lerp(luminanceColor, finalColor, _Saturation);

					//对比度控制
					fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
					finalColor = lerp(avgColor, finalColor, _Contrast);

					return fixed4(finalColor, renderTex.a);
				}

				ENDCG
		}
    }
	
	//不返回其他控制
	Fallback Off
}
