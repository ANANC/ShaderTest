Shader "Custom/10 Mirror"
{
    Properties
    {
	   _MainTex("镜面纹理",2D) = "White"{}
    }
    SubShader
    {
	   Pass{
				Tags { "LightMode" = "ForwardBase"}	//正向渲染路径的bassPass通道的光照模式 逐像素渲染平行光

				CGPROGRAM							//开始渲染标志位

				#pragma vertex vert					//定义顶点着色器的名字
				#pragma fragment frag				//定义片元着色的名字

				#include "Lighting.cginc"			//灯光内置控制器 标记引用

				sampler2D _MainTex;

				struct a2v {
					float4 vertex:POSITION;
					float4 texcoord:TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv:TEXCOORD0;
				};

				v2f vert(a2v v)
				{
					v2f o;

					//裁剪空间坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//镜面纹理
					o.uv = v.texcoord;

					//反转镜面纹理
					o.uv.x = 1 - o.uv.x;

					return o;
				}

				fixed4 frag(v2f i) :SV_Target{
					return tex2D(_MainTex,i.uv);
				}

				ENDCG								//结束渲染标志位
			}
    }
    FallBack "Diffuse"
}
