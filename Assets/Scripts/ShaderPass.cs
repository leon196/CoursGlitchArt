using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ShaderPass : MonoBehaviour
{
	public Material materialShader;
	public string uniformName = "_ShaderPassTexture";
	public RenderTextureFormat textureFormat = RenderTextureFormat.ARGB32;
	public FilterMode filterMode = FilterMode.Point;
	[Range(1,16)] public int levelOfDetails = 1;

	private FrameBuffer frameBuffer;
	private RenderTexture output;

	void Start ()
	{
		frameBuffer = new FrameBuffer(Screen.width, Screen.height, 2, textureFormat, filterMode);
	}

	void Update ()
	{
		if (materialShader) {
			Shader.SetGlobalTexture(uniformName, frameBuffer.Apply(materialShader));
		}
	}

	public void ChangeLevelOfDetails (int dt)
	{
		levelOfDetails = (int)Mathf.Clamp(levelOfDetails + dt, 1, 16);
		frameBuffer = new FrameBuffer(Screen.width/levelOfDetails, Screen.height/levelOfDetails, 2, textureFormat, filterMode);
	}

	public void Print (Texture2D texture)
	{
		frameBuffer.Print(texture);
	}
}
