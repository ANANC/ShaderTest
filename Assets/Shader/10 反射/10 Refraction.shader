// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/10 Refraction"
{
    Properties
    {
        _Color ("漫反射", Color) = (1,1,1,1)
		_RefractColor("折射光",Color) = (1,1,1,1)
		_RefractAmount("折射程度",Range(0,1)) = 1
		_RefractRatio("投射比",Range(0.1,1)) = 0.5
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
			fixed4 _RefractColor;
			fixed	_RefractAmount;
			fixed	_RefractRatio;
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
				fixed3 worldRefr : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;

				//裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//世界空间法线
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//世界空间坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//世界空间视图方向
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

				//世界空间折射方向 refract
				o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//世界空间法线 归一化
				fixed3 worldNormal = normalize(i.worldNormal);

				//世界空间光线角度 归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				//折射颜色 = 环境纹理采样 * （用户定义）折射颜色
				fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractColor.rgb;

				//光线衰弱
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				//颜色 = 环境光 + （漫反射，折射）的插值 * 光线衰弱
				fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) * atten;

				return fixed4(color, 1);
			}


			ENDCG								//结束渲染标志位
		}
    }
		
		FallBack "Reflective/VertexLit"
}
