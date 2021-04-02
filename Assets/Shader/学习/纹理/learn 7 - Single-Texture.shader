Shader "Custom/learn 7 - Single-Texture"
{
    Properties
    {
        _Diffuse ("漫反射", Color) = (1,1,1,1)
        _MainTex ("纹理图", 2D) = "white" {}
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
			fixed4 _Specular;					//高光颜色
			float _Gloss;						//高光强度

			struct a2v {
				float4 vertex:POSITION;			//（应用空间）坐标
				float3 normal:NORMAL;			//（应用空间）法线
				float4 texcoord:TEXCOORD0;		//（应用空间）纹理
			};

			struct v2f {
				float4 pos:SV_POSITION;			//（裁剪空间）坐标
				float3 worldNormal:TEXCOORD0;	//（世界空间）法线
				float3 worldPos:TEXCORRD1;		//（世界空间）坐标
				float2 uv:TEXCOORD2;			//纹理偏移
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;

				//得到裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//得到世界空间的法线
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				//得到世界空间的坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//纹理偏移 = 纹理 * 纹理缩放值 + 纹理偏移值
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

				// 归一化世界空间法线
				fixed3 worldNormal = normalize(i.worldNormal);
				
				//得到光源
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
				//归一化光源
				worldLightDir = normalize(worldLightDir);
				
				//贴图颜色 = 纹理颜色 * （用户输入）漫反射颜色
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;
				
				//漫反射亮度 范围：[0)
				fixed lightness = max(0, dot(worldNormal, worldLightDir));

				//漫反射颜色 = 通道光颜色 * 反射颜色 * 亮度
				fixed3 diffuse = _LightColor0.rbg * albedo * lightness;

				//视图方向并归一化
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//半角方向
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//高光亮度 范围[0)
				fixed specularLightness = pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				//高光颜色 = 通道光颜色 * （用户输入）高光颜色 * 高光亮度
				fixed3 specular = _LightColor0.rbg * _Specular.rbg * specularLightness;

				//环境光 = 环境光 * 反射颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//片元颜色
				float3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}
