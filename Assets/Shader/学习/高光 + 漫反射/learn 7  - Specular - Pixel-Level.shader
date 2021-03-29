// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/learn 7 - Specular - Pixel-Level"
{
	Properties
	{
		_Diffuse("Diffuse 漫反射", Color) = (1,1,1,1)
		_Specular("Specular 高光", Color) = (1,1,1,1)
		_Gloss("Gloss 高光区域",Range(8.0,256)) = 20
		_OnlySpecular("开启漫反射",Range(0,1)) = 0
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
			fixed4 _Specular;				    //高光颜色
			float _Gloss;						//高光区域
			float _OnlySpecular;
			

			//顶点着色器的输入结构体 application to vertex 应用程序传递到顶点着色器
			struct a2v {
				float4 vertex:POSITION;			//坐标
				float3 normal:NORMAL;			//顶点法线信息
			};

			//顶点着色器的输出结构体/片元着色器的输入结构体 vertex to fragment 顶点着色器传递到片元着色器
			struct v2f {
				float4 pos:SV_POSITION;			//（裁剪空间）顶点位置
				fixed3 worldNormal : TEXCOORD0;	//(世界空间）法线
				float3 worldPos:TEXCOORD1;		//（世界空间）顶点位置
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;

				//进行 （模型)M(世界)V(观察)P(裁剪) 坐标转换
				o.pos = UnityObjectToClipPos(v.vertex);

				//世界空间的法线
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				
				//坐标转换 得世界空间的坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//归一化世界空间法线
			    float3 worldNormal = normalize(i.worldNormal);

				//归一化光源
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//明度
				fixed lightness = dot(worldNormal, worldLight);
				lightness = saturate(lightness);

				//计算出漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightness;

				//计算出基于法线的入射灯光的反射方向
				fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));

				//世界空间的视图方向 = 归一化（世界空间下顶点坐标 指向 世界空间下的摄像机位置 的方向 ）
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				// 得到 出射光 和 视图方向 的角度。 并规范在[0,1]的范围内。
				fixed specularPower = saturate(dot(reflectDir, viewDir));
				// 得到specularPower 的 _Gloss次幂  高光强度的控制
				specularPower = pow(specularPower, _Gloss);

				//高光 = 光源颜色 * 用户定义的高光颜色 * 高光强度控制
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * specularPower;

				//顶点颜色 = 环境光 + 漫反射
				float3 color = ambient + diffuse;

				//是否屏蔽掉光效
				color = color * _OnlySpecular;

				//顶点颜色 + 高光
				color = color + specular;

				return fixed4(color,1.0);	//颜色输出
			}
			

			ENDCG								//结束渲染标志位
		}
	}

    FallBack "Specular"
}
