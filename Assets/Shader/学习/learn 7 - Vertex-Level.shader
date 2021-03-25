// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/learn 7 - Vertex-Level"
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
				float4 pos:SV_POSITION;			//顶点位置
				fixed3 color : COLOR;			//片元的颜色
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;

				//进行 （模型)M(世界)V(观察)P(裁剪) 坐标转换
				o.pos = UnityObjectToClipPos(v.vertex);

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//normalize函数：归一化
				//v.normal = 顶点的法线
				//mul函数：相乘
				//unity_WorldToObject：当前世界矩阵的逆矩阵 （内置变量）
				//（世界空间）法线 = （模型空间）法线 * 逆世界矩阵 [使用于等比/非等比缩放的情况]
				//（世界空间）法线 = 世界矩阵 * （模型空间）法线   [使用于等比缩放的情况]
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				//_WorldSpaceLightPos0 ：当前世界空间的光源（内置变量）
				//_WorldSpaceLightPos0.w 代表是光的类型 0=平行光，1=点光源/聚光灯
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//_LightColor0：光源颜色
				//_Diffuse：用户定义的颜色（外部传递变量）

				// dot(worldNormal, worldLight) = 法线 点乘 指向光源方向 = 法线和指向光源方向的角度。 如果是负数，说明光是从背面照射，忽略掉。夹角越小，光照越大。
				//saturate：数值规范化（0-1）。 
				//计算后的明度用于颜色的控制。角度越小，光照越大，颜色越明亮，角度越大，光照越小，颜色越暗淡。
				fixed lightness = dot(worldNormal, worldLight);
				lightness = saturate(lightness);

				//当前通道光源颜色 * 用户配置的漫反射颜色 * 明度
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightness;

				//当前点颜色 = 环境光 + （综合的）漫反射
				o.color = ambient + diffuse;

				return o;
			}


			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				return fixed4(i.color,1.0);	//直接将顶点着色器计算的颜色作为最终的颜色输出
			}

			ENDCG								//结束渲染标志位
		}
    }
    FallBack "Diffuse"
}
