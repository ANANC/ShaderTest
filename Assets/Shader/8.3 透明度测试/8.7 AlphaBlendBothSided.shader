Shader "Custom/8.7 AlphaBlendBothSided"
{
	Properties
	{
		_Color("漫反射颜色", Color) = (1,1,1,1)
		_MainTex("纹理图", 2D) = "white" {}
		_AlphaScale("透明度" ,  Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"				//渲染顺序 AlphaTest = 2450
			"IgnoreProjector" = "Ture"			//无视投影器
			"RenderType" = "Transparent"		//类型：半透明
		}


		Pass
		{
			Tags{"LightMode" = "ForwardBase"}	//光照类型：向前渲染

			Cull Front							//正面剔除

			ZWrite Off							//关掉深度测试
			Blend SrcAlpha OneMinusSrcAlpha		//设置源颜色（该片元着色器产生的颜色）的混合因子设为ScrAlpha, 设置目标颜色（已经存在于颜色缓冲重的颜色）的混合因子设为OneMinusScrAlpha

			CGPROGRAM							//开始渲染标志位

			#pragma vertex vert					//定义顶点着色器的名字
			#pragma fragment frag				//定义片元着色的名字

			#include "Lighting.cginc"

			fixed4 _Color;						//漫反射颜色
			sampler2D _MainTex;					//纹理图
			float4 _MainTex_ST;					//纹理图坐标
			fixed _AlphaScale;					//透明度

			struct a2v {
				float4 vertex:POSITION;			//（应用空间）坐标
				float3 normal:NORMAL;			//（应用空间）法线
				float4 texcoord:TEXCOORD0;		//纹理
			};

			struct v2f {
				float4 pos:SV_POSITION;			//（裁剪空间）坐标
				float3 worldNormal:TEXCOORD0;	//（世界空间）法线
				float3 worldPos:TEXCOORD1;		//（世界空间）坐标
				float2 uv:TEXCOORD2;			//纹理偏移
			};

			v2f vert(a2v v) {
				v2f o;
				//得到裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//世界空间坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//世界空间法线
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//计算偏移坐标 顶点和材质球的缩放和偏移值进行计算，得到偏移坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//归一化世界空间法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//得到世界空间光源并归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//得到顶点的纹理图颜色
				fixed4 texColor = tex2D(_MainTex, i.uv);

				//得到贴图颜色
				fixed3 albedo = texColor.rgb * _Color.rgb;

				//得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//得到漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				//得到片元的透明度
				float alpha = texColor.a * _AlphaScale;

				return fixed4(ambient + diffuse, alpha);
			}

			ENDCG
		}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}	//光照类型：向前渲染

			Cull Back							//背面剔除

			ZWrite Off							//关掉深度测试
			Blend SrcAlpha OneMinusSrcAlpha		//设置源颜色（该片元着色器产生的颜色）的混合因子设为ScrAlpha, 设置目标颜色（已经存在于颜色缓冲重的颜色）的混合因子设为OneMinusScrAlpha

			CGPROGRAM							//开始渲染标志位

			#pragma vertex vert					//定义顶点着色器的名字
			#pragma fragment frag				//定义片元着色的名字

			#include "Lighting.cginc"

			fixed4 _Color;						//漫反射颜色
			sampler2D _MainTex;					//纹理图
			float4 _MainTex_ST;					//纹理图坐标
			fixed _AlphaScale;					//透明度

			struct a2v {
				float4 vertex:POSITION;			//（应用空间）坐标
				float3 normal:NORMAL;			//（应用空间）法线
				float4 texcoord:TEXCOORD0;		//纹理
			};

			struct v2f {
				float4 pos:SV_POSITION;			//（裁剪空间）坐标
				float3 worldNormal:TEXCOORD0;	//（世界空间）法线
				float3 worldPos:TEXCOORD1;		//（世界空间）坐标
				float2 uv:TEXCOORD2;			//纹理偏移
			};

			v2f vert(a2v v) {
				v2f o;
				//得到裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//世界空间坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//世界空间法线
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//计算偏移坐标 顶点和材质球的缩放和偏移值进行计算，得到偏移坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//归一化世界空间法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//得到世界空间光源并归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//得到顶点的纹理图颜色
				fixed4 texColor = tex2D(_MainTex, i.uv);

				//得到贴图颜色
				fixed3 albedo = texColor.rgb * _Color.rgb;

				//得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//得到漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				//得到片元的透明度
				float alpha = texColor.a * _AlphaScale;

				return fixed4(ambient + diffuse, alpha);
			}

			ENDCG
		}

	}

	FallBack "Transparent/VertexLit"
}
