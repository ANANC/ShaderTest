Shader "Custom/learn 7 -Ramp-Texture"
{
    Properties
    {
		_Diffuse("漫反射", Color) = (1,1,1,1)
        _RampTex ("渐变纹理", 2D) = "white" {}
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
			sampler2D _RampTex;					//纹理
			float4 _RampTex_ST;					//纹理坐标
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
				float3 worldPos:TEXCOORD1;		//（世界空间）坐标
				float2 uv:TEXCOORD2;			//纹理偏移
			};

			v2f vert(a2v v)
			{
				v2f o;

				//得到裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//世界空间坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//世界空间法线
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//计算偏移坐标 顶点和材质球的缩放和偏移值进行计算，得到偏移坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//归一化世界空间法线
				fixed3 worldNormal = normalize(i.worldNormal);
				
				//得到世界空间光源并归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//得到通道光源 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//得到漫反射亮度
				fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;

				//得到顶点在纹理上的颜色
				fixed3 texUVColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;

				//得到漫反射颜色
				fixed3 diffuseColor = _LightColor0.rbg * texUVColor * _Diffuse.rbg;

				//得到世界空间视图并归一化
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//得到半角方向
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//得到高光亮度
				fixed specularLightness = pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				//得到高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * specularLightness;

				return fixed4(ambient + diffuseColor + specular, 1.0f);
			}

			ENDCG
		}
    }
    FallBack "Specular"
}
