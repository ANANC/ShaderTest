// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/10 Reflection"
{
    Properties
    {
        _Color ("环境光", Color) = (1,1,1,1)
        _ReflectColor("反射颜色",Color) = (1,1,1,1)
		_ReflectAmount("反射程度",Range(0,1)) = 1
		_Cubemap("环境映射纹理",Cube) = "_Skybox"{}
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

			fixed4 _Color;						//环境光
			fixed4 _ReflectColor;				//反射颜色
			fixed _ReflectAmount;				//反射程度
			samplerCUBE _Cubemap;				//环境映射纹理

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

				//（裁剪空间）坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//（世界空间）法线
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//（世界空间）坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//（世界空间）视图方向
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

				//（世界空间）反射方向
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//归一化 世界法线
				fixed3 worldNormal = normalize(i.worldNormal);
				//归一化 世界灯光朝向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//归一化 世界视图
				fixed3 worldViewDir = normalize(i.worldViewDir);

				//灯光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				//反射 = 根据当前角度对天空盒进行采样 * 反射颜色
				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;

				//灯光衰弱
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				//环境光 + （漫反射，反射）的插值 * 灯光衰弱
				fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

				return fixed4(color, 1.0);
			}

			ENDCG								//结束渲染标志位
		}
    }
		
	FallBack "Reflective/VertexLit"
}
