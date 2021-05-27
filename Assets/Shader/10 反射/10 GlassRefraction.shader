// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/10 GlassRefraction"
{
    Properties
    {
		_MainTex("纹理",2D) = "white" {}
		_BumpMap("法线纹理",2D) = "bump" {}
		_Cubemap("环境纹理",Cube) = "_Skybox" {}
		_Distortion("扭曲系数",Range(0,100)) = 10
		_RefractiAmount("折射系数",Range(0.0,1.0)) = 1.0
	}

	SubShader
	{
		Tags{
			"Queue" = "Transparent"
			"RenderType" = "Opaque"
		}

		GrabPass{"_RefractionTex"}	//定义渲染队列，使用GrabPass获取屏幕图像

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			sampler2D _MainTex;						//主纹理
			float4 _MainTex_ST;						//主纹理偏移
			sampler2D _BumpMap;						//法线纹理
			float4 _BumpMap_ST;						//法线纹理偏移
			samplerCUBE _Cubemap;					//环境纹理
			float _Distortion;						//扭曲系数
			fixed _RefractAmount;					//折射系数
			sampler2D _RefractionTex;				//GrabPass通道指定纹理名
			float4 _RefractionTex_TexelSize;		//GrabPass通道指定纹理大小名

			struct a2v {
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
				float4 tangent:TANGENT;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 scrPos:POSITION;
				float4 uv:TEXCOORD0;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//得到裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//在GrabPass界面中的位置
				o.scrPos = ComputeGrabScreenPos(o.pos);

				//主纹理采样
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				//法线纹理采样
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				//世界坐标
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//世界空间法线
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);

				//世界空间切线
				float worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

				//世界空间副法线
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				//将数据记录到寄存器中
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//世界空间坐标
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

				//世界空间视图方向
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				//法线采样
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				//偏移 = 法线 * 扭曲系数 * 玻璃采样纹理坐标
				float2 offset = bump.xy * _Distorrion * _RefractionTex_TexelSize.xy;

				//玻璃纹理坐标 = 偏移 + （原）玻璃纹理坐标
				i.scrPos.xy = offset + i.scrPos.xy;

				//玻璃纹理采样
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

				//法线采样
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				//折射光线方向
				fixed3 reflDir = reflect(-worldViewDir, bump);

				//主纹理采样
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);

				//环境采样
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

				fixed3 finalColor = reflColor * (1 - _RefractAmount) + refrCol * _RefractAmount;

				return fixed4(finalCoLOR, 1);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
