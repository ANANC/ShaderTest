Shader "Custom/11 ScrollingBackground"
{
    Properties
    {
		_MainTex("底层图片", 2D) = "white" {}
		_DetailTex("表层图片",2D) = "white" {}
		_ScrollX("底层图片速度",Float) = 1.0
		_Scroll2X("表层图片速度",Float) = 1.0
		_Multiplier("纹理的整体亮度",Float) = 1
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DetailTex;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

			struct a2v
			{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				
				//frac 返回参数的小数部分 用小数更平滑
				//底层纹理随着时间的偏差值 
				float xyDiscrepancy = frac(float2(_ScrollX, 0.0) * _Time.y);

				//底层纹理坐标 = 起始纹理坐标 + 偏差值
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + float2(xyDiscrepancy, 0);

				//表层纹理随时间的偏差值
				float zwDiscrepancy = frac(float2(_Scroll2X, 0.0) * _Time.y);

				//表层纹理坐标 = 起始纹理坐标 + 偏差值
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + float2(zwDiscrepancy, 0);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//底层纹理采样
				fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);

				//表层纹理采样
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);

				//lerp函数：得到插值 （a,b,w) 根据w,得到从a到b的插值
				//得到底层纹理到表层纹理的插值
				fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);

				//颜色*亮度
				c.rgb *= _Multiplier;

				return c;
			}

			ENDCG
		}
       
    }

    FallBack "VertexLit"
}
