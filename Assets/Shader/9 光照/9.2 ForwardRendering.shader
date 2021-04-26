// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/9.2 ForwardRendering"
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
		Tags { "LightMode" = "ForwardBase"}	//正向渲染路径的bassPass通道的光照模式 逐像素渲染平行光

		CGPROGRAM							//开始渲染标志位

		#pragma multi_compile_fwdbase		//标记为base模式渲染

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

			//世界空间的视图方向 = 归一化（世界空间下顶点坐标 指向 世界空间下的摄像机位置 的方向 ）
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

			// 半角向量 = 指向光源方向 + 指向摄像机方向
			fixed3 halfDif = normalize(worldLight + viewDir);

			// 得到 法线 和 半角向量 的夹角
			fixed specularPower = dot(worldNormal, halfDif);

			// 得到 [0) 的范围
			specularPower = max(0, specularPower);

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

			//衰弱值 平行光没有衰弱
			fixed atten = 1.0;

			color = color * atten;

			return fixed4(color,1.0);	//颜色输出
		}

		ENDCG								//结束渲染标志位

		}

	Pass{
		Tags { "LightMode" = "ForwardAdd"}	//正向渲染路径的additionalPass通道的光照模式 逐像素渲染任何光

		Blend One One						//使用混合模式 线性变淡. 不使用混合模式，光源会进行覆盖

		CGPROGRAM							//开始渲染标志位

		#pragma multi_compile_fwdadd		//标记为add模式渲染

		#pragma vertex vert					//定义顶点着色器的名字
		#pragma fragment frag				//定义片元着色的名字

		#include "Lighting.cginc"			//灯光内置控制器 标记引用
		#include "AutoLight.cginc"

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
#ifdef USING_DIRECTIONAL_LIGHT
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
#else
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
#endif

			//明度
			fixed lightness = dot(worldNormal, worldLight);
			lightness = saturate(lightness);

			//计算出漫反射颜色
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightness;

			//世界空间的视图方向 = 归一化（世界空间下顶点坐标 指向 世界空间下的摄像机位置 的方向 ）
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

			// 半角向量 = 指向光源方向 + 指向摄像机方向
			fixed3 halfDif = normalize(worldLight + viewDir);

			// 得到 法线 和 半角向量 的夹角
			fixed specularPower = dot(worldNormal, halfDif);

			// 得到 [0) 的范围
			specularPower = max(0, specularPower);

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

			//光照衰弱
#ifdef USING_DIRECTIONAL_LIGHT
			fixed atten = 1.0f;		//平行光没有衰弱
#else
			float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;						//世界转光线矩阵和世界空间坐标相乘 = 光线空间坐标
			float3 distanceSquare = dot(lightCoord, lightCoord);						//顶点距离的平方 点乘
			float2 lightTexturePos = distanceSquare.rr;									//获取对象的rgb值中的r作为新坐标（r,r)
			fixed atten = tex2D(_LightTexture0, lightTexturePos).UNITY_ATTEN_CHANNEL;	//纹理采样后，UNITY_ATTEN_CHANNEL = 得到衰弱值所在的分量
#endif

			color = color * atten;

			return fixed4(color,1.0);	//颜色输出
		}

		ENDCG								//结束渲染标志位

		}

	}

		
	FallBack "Specular"
}
