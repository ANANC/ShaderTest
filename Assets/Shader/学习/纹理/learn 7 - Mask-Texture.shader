Shader "Custom/learn 7 - Mask-Texture"
{
    Properties
    {
		_Diffuse("漫反射", Color) = (1,1,1,1)
		_MainTex("纹理图", 2D) = "white" {}
		_BumpMap("法线图",2D) = "white" {}
		_BumpScale("凹凸程度",Float) = 1.0
		_SpecularMask("高光遮罩",2D) = "white" {}
		_SpecularpScale("高光程度",Float) = 1.0
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
			sampler2D _SpecularMask;			//高光遮罩
			float _SpecularScale;				//高光程度
			fixed4 _Specular;					//高光颜色
			float _Gloss;						//高光强度

			struct a2v {
				float4 vertex:POSITION;			//（应用空间）坐标
				float3 normal:NORMAL;			//（应用空间）法线
				float4 tangent:TANGENT;			//（应用空间）切线
				float4 texcoord:TEXCOORD0;		//（应用空间）纹理
			};

			struct v2f {
				float4 pos:SV_POSITION;				//（裁剪空间）坐标
				float2 uv:TEXCOORD0;				//纹理偏移
				float3 tangentLightDir:TEXCOORD1;	//（切线空间）光源 
				float3 tangentViewDir:TEXCOORD2;	//（切线空间）视图
			};


			v2f vert(a2v v)
			{
				v2f o;

				//得到裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//纹理坐标 顶点*缩放+偏移
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				//计算世界空间->切线空间的矩阵
				TANGENT_SPACE_ROTATION;

				//得到切线空间的光源
				o.tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

				//得到切线空间的视图
				o.tangentViewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//归一化切线空间光源
				fixed3 tangentLigthDir = normalize(i.tangentLightDir);

				//归一化切线空间视图
				fixed3 tangentViewDir = normalize(i.tangentViewDir);

				//得到切线空间的法线
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				//控制切线的强度
				tangentNormal.xy *= _BumpScale;
				//得到副切线
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				//得到纹理颜色
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;

				//得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//得到漫反射
				fixed3 diffuse = _LightColor0.rbg * albedo * max(0, dot(tangentNormal, tangentNormal));

				//得到半角方向
				fixed3 halfDir = normalize(tangentLigthDir + tangentViewDir);

				//得到遮罩纹理并控制强度 只要遮罩纹理的R通道
				fixed speculatMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;

				//得到高光的亮度
				fixed speculatLightness = pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

				//得到高光
				fixed3 specular = _LightColor0.rgb * _Specular.rbg * speculatLightness * speculatMask;

				return fixed4(ambient + diffuse + specular, 1.0);
			}


			ENDCG
		}
    }
    FallBack "Specular"
}
