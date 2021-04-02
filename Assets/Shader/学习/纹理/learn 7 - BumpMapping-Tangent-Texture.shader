Shader "Custom/learn 7 - BumpMapping-Tangent-Texture"
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
				float3 lightDir:TEXCOORD1;		//光源方向
				float3 viewDir:TEXCOORD2;		//视图方向
			};

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

				//归一化法线
				float3 normalizeNormal = normalize(v.normal);

				//归一化切线
				float3 normalizeTanget = normalize(v.tangent.xyz);

				//构造切线空间的坐标系。 之后可以使用rotation来代表世界空间到切线空间的矩阵 world->tangent
				//将世界空间的切线都统一到切线空间进行计算,统一坐标系
				TANGENT_SPACE_ROTATION;

				//切线空间的光线 = （world->tangent）矩阵 * (模型空间)光源
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

				//切线空间的视图 = （world->tangent）矩阵 * （模型空间）视图
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}


			fixed4 frag(v2f i) : SV_Target{
				//归一化切线空间的光源方向
				fixed3 tangentLightDir = normalize(i.lightDir);

				//归一化切线空间的视图方向
				fixed3 tangentViewDir = normalize(i.viewDir);
				
				//得到法线贴图内容 = 法线图上的法线偏移坐标
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

				//切线空间的法线
				fixed3 tangentNormal;

				//得到切线空间的法线 = 解包法线贴图
				tangentNormal = UnpackNormal(packedNormal);

				//法线控制强度
				tangentNormal.xy *= _BumpScale;

				//副法线计算
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				//贴图颜色 = 纹理颜色 * （用户输入）漫反射颜色
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;

				//环境光 = 环境光 * 反射颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射亮度 范围：[0) 切线空间的法线 * 切线空间的光源
				fixed lightness = max(0, dot(tangentNormal, tangentLightDir));

				//漫反射颜色 = 通道光颜色 * 反射颜色 * 亮度
				fixed3 diffuse = _LightColor0.rbg * albedo * lightness;

				//半角方向 切线空间法线 + 切线空间视图方向
				fixed3 halfDir = normalize(tangentNormal + tangentViewDir);

				//高光亮度 范围[0)
				fixed specularLightness = pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

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
