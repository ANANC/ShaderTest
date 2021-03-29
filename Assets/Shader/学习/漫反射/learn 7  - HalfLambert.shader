Shader "Custom/learn 7 - HalfLambert"
{
	Properties
	{
		_Diffuse("Diffuse 漫反射", Color) = (1,1,1,1)
	}
		SubShader
	{
		Pass{
			Tags { "LightMode" = "ForwardBase"}	//正向渲染路径的bassPass通道的光照模式 逐顶点渲染平行光

			CGPROGRAM							//开始渲染标志位

			#pragma vertex vert					//定义顶点着色器的名字
			#pragma fragment frag				//定义片元着色的名字

			#include "Lighting.cginc"			//灯光内置控制器 标记引用

			// 定义数据结构
			fixed4 _Diffuse;					//变量 对应Properties中漫反射属性 名字相同


			//顶点着色器的输入结构体 application to vertex 应用程序传递到顶点着色器
			struct a2v {
				float4 vertex:POSITION;			//坐标
				float3 normal:NORMAL;			//顶点法线信息
			};

			//顶点着色器的输出结构体/片元着色器的输入结构体 vertex to fragment 顶点着色器传递到片元着色器
			struct v2f {
				float4 pos:SV_POSITION;			//（裁剪空间）顶点位置
				fixed3 worldNormal : TEXCOORD0;	//顶点纹理坐标
			};


			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;

				//进行 （模型)M(世界)V(观察)P(裁剪) 坐标转换
				o.pos = UnityObjectToClipPos(v.vertex);

				// 计算世界空间的法线
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//归一化世界空间的法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//归一化光源
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//明度的范围控制在 [-1,1]
				fixed halfLambert = dot(worldNormal, worldLight) * 0.5 + 0.5;

				//计算出漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

				//片元颜色 环境光+漫反射
				fixed3 color = ambient + diffuse;

				return fixed4(color, 1.0);
			}

		ENDCG								//结束渲染标志位
	}
	}
		FallBack "Diffuse"
}
