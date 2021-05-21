// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/10 Fresnel"
{
    Properties
    {
        _Color ("漫反射", Color) = (1,1,1,1)
		_FresnelScale("菲涅尔反射比例",Range(0,1)) = 0.5
		_Cubemap("环境映射纹理",Cube) = "_Skybox" {}
	}
		SubShader
	{
			Pass{
				Tags { "LightMode" = "ForwardBase"}	//正向渲染路径的bassPass通道的光照模式 逐像素渲染平行光

				CGPROGRAM							//开始渲染标志位

				#pragma vertex vert					//定义顶点着色器的名字
				#pragma fragment frag				//定义片元着色的名字

				#include "Lighting.cginc"			//灯光内置控制器 标记引用
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed _FresnelScale;
				samplerCUBE	_Cubemap;
				
				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					fixed3 worldNormal : TEXCOORD1;
					fixed3 worldViewDir : TEXCOORD2;
					fixed3 worldRefl : TEXCOORD3;
					SHADOW_COORDS(4)
				};

				v2f vert(a2v v)
				{
					v2f o;

					//裁剪空间坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//世界空间法线
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

					//世界空间坐标
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					//世界空间视图
					o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

					//世界空间反射方向
					o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

					TRANSFER_SHADOW(o);

					return o;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					//归一化世界空间法线
					fixed3 worldNormal = normalize(i.worldNormal);

					//世界空间光线 归一化
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					//归一化世界空间视图
					fixed3 worldViewDir = normalize(i.worldViewDir);

					//环境光
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

					//光线衰弱
					UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

					//反射颜色
					fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;

					//折射 = 基础折射比 + 补充折射比 * (反（视图和法线的夹角）)的5的次幂
					fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
					//规范在（0，1）
					fresnel = saturate(fresnel);

					//漫反射
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

					fixed3 color = ambient + lerp(diffuse, reflection, fresnel) * atten;

					return fixed4(color, 1.0);
				}

				ENDCG								//结束渲染标志位
			}
    }
    FallBack "Diffuse"
}
