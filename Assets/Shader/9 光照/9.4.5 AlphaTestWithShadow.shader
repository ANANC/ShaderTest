Shader "Custom/9.4.5 AlphaTestWithShadow"
{

	//阴影没正确透明实现
	Properties
	{
		_Color("漫反射颜色", Color) = (1,1,1,1)
		_MainTex("纹理图", 2D) = "white" {}
		_Cutoff("透明裁剪度" ,  Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"				//渲染顺序 AlphaTest = 2450
			"IgnoreProjector" = "Ture"			//无视投影器
			"RenderType" = "TransparentCutout"	//类型：遮罩透明度 （透明镂空，两个通道植被着色器）
		}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}	//光照类型：向前渲染

			Cull Off							//关闭剔除

			CGPROGRAM							//开始渲染标志位

			#pragma multi_compile_fwdbase

			#pragma vertex vert					//定义顶点着色器的名字
			#pragma fragment frag				//定义片元着色的名字

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;						//漫反射颜色
			sampler2D _MainTex;					//纹理图
			float4 _MainTex_ST;					//纹理图坐标
			fixed _Cutoff;						//透明裁剪度

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
				SHADOW_COORDS(3)				//阴影纹理采样	数字对应的是插值寄存器Index
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

				//阴影纹理采样
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//归一化世界空间法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//得到世界空间光源并归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//得到顶点的纹理图颜色
				fixed4 texColor = tex2D(_MainTex, i.uv);

				//丢弃掉小于用户指定的透明度的像素点
				fixed contrastAlphat = texColor.a - _Cutoff;
				clip(contrastAlphat);

				//得到贴图颜色
				fixed3 albedo = texColor.rgb * _Color.rgb;

				//得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//得到漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				
				//计算光线衰弱+阴影
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				fixed3 color = ambient + diffuse * atten;

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Transparent/Cutout/VertexLit"
}
