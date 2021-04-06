// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/learn 7 - NormalMap-World-Texture"
{
	Properties
	{
		_Diffuse("漫反射", Color) = (1,1,1,1)
		_MainTex("纹理图", 2D) = "white" {}
		_BumpMap("法线图",2D) = "white" {}
		_BumpScale("凹凸程度",Float) = 1.0
		_Specular("高光颜色", Color) = (1,1,1,1)
		_Gloss("高光强度", Range(8.0,256)) = 20
	}

		SubShader
		{
			Pass
			{
				Tags { "LightMode" = "ForwardBase"}	//正向渲染路径的bassPass通道的光照模式 逐顶点渲染平行光

				CGPROGRAM							//开始渲染标志位

				#pragma vertex vert					//定义顶点着色器的名字
				#pragma fragment frag				//定义片元着色的名字

				#include "Lighting.cginc"

				fixed4 _Diffuse;					//漫反射颜色
				sampler2D _MainTex;					//纹理
				float4 _MainTex_ST;					//纹理坐标
				sampler2D _BumpMap;					//法线图
				float4 _BumpMap_ST;					//法线坐标
				float _BumpScale;					//凹凸程度
				fixed4 _Specular;					//高光颜色
				float _Gloss;						//高光强度

				struct a2v {
					float4 vertex:POSITION;			//（应用空间）坐标
					float3 normal:NORMAL;			//（应用空间）法线
					float4 tangent:TANGENT;			//（应用空间）切线
					float4 texcoord:TEXCOORD0;		//（应用空间）纹理
				};

				struct v2f {
					float4 pos:SV_POSITION;			//（裁剪空间）坐标
					float4 uv:TEXCOORD0;			//纹理偏移
					float4 TtoW0:TEXCORRD1;			//切线空间->世界空间 的 矩阵 第一行
					float4 TtoW1:TEXCORRD2;			//切线空间->世界空间 的 矩阵 第二行
					float4 TtoW2:TEXCORRD3;			//切线空间->世界空间 的 矩阵 第三行
				};

				/*
				切线空间->世界空间 的 矩阵   = 
				| TtoW0.x TtoW0.y TtoW0.z |		| worldTangent.x, worldBinormal.x, worldNormal.x |
				| TtoW1.x TtoW1.y TtoW1.z |		| worldTangent.y, worldBinormal.y, worldNormal.y |
				| TtoW2.x TtoW2.y TtoW2.z |		| worldTangent.z, worldBinormal.z, worldNormal.z |

				(世界空间）顶点坐标
				（TtoW0.w,TtoW1.w,TtoW2.w) = （worldPos.x,worldPos.y,worldPos.z）
				*/

				//顶点着色器
				v2f vert(a2v v)
				{
					v2f o;

					//得到裁剪空间坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//纹理偏移 = 纹理 * 纹理缩放值 + 纹理偏移值
					o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

					//法线偏移 = 纹理 * 法线纹理的缩放值 + 法线纹理偏移值 副法线（w)
					o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

					//世界空间坐标
					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					//世界空间法线
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);

					//世界空间切线
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

					//世界空间副法线
					fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

					//切线空间->世界空间 的矩阵	 w:世界空间的坐标
					o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
					o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
					o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

					return o;
				}


				fixed4 frag(v2f i) : SV_Target{
					//世界空间坐标
					float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

					//世界空间光照 并 归一化
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					
					//世界空间视图 并 归一化
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

					//得到当前顶点的法线贴图的内容 uv.zw=法线偏移值
					fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
					
					//控制法线的强度
					bump.xy *= _BumpScale;
					
					//计算出副法线
					bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

					//得到世界空间法线 通过矩阵的每一行和法线进行点乘，将法线变换到世界空间
					float worldTangentX = dot(i.TtoW0.xyz, bump);
					float worldTangentY = dot(i.TtoW1.xyz, bump);
					float worldTangentZ = dot(i.TtoW2.xyz, bump);
					
					//得到世界空间的法线
					fixed3 worldTangent = normalize(half3(worldTangentX, worldTangentY, worldTangentZ));

					//贴图颜色 = 纹理颜色 * （用户输入）漫反射颜色
					fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;

					//环境光 = 环境光 * 反射颜色
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					//漫反射亮度 范围：[0) 切线空间的法线 * 切线空间的光源
					fixed lightness = max(0, dot(worldTangent, lightDir));

					//漫反射颜色 = 通道光颜色 * 反射颜色 * 亮度
					fixed3 diffuse = _LightColor0.rbg * albedo * lightness;

					//半角方向 切线空间法线 + 切线空间视图方向
					fixed3 halfDir = normalize(worldTangent + viewDir);

					//高光亮度 范围[0)
					fixed specularLightness = pow(max(0, dot(worldTangent, halfDir)), _Gloss);

					//高光颜色 = 通道光颜色 * （用户输入）高光颜色 * 高光亮度
					fixed3 specular = _LightColor0.rbg * _Specular.rbg * specularLightness;

					//片元颜色
					float3 color = ambient + diffuse + specular;

					return fixed4(color, 1.0);
				}

				ENDCG
			}
		}
			
		FallBack "Specular"
}
